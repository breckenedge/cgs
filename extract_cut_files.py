import adsk.core, adsk.fusion, traceback, os

THICKNESSES_CM = [1.905, 1.27, 0.635, 0.47625, 0.3175]   # 3/4", 1/2", 1/4", 3/16", 1/8"
THICKNESS_NAMES = ['0.75in', '0.5in', '0.25in', '0.1875in', '0.125in']
TOLERANCE_CM    = 0.01

def run(context):
    app = adsk.core.Application.get()
    ui  = app.userInterface
    try:
        dlg = ui.createFolderDialog()
        dlg.title = 'Select DXF Output Folder'
        if dlg.showDialog() != adsk.core.DialogResults.DialogOK:
            return
        out_folder = dlg.folder

        exported, skipped = [], []

        for doc in app.documents:
            product = doc.products.itemByProductType('DesignProductType')
            design  = adsk.fusion.Design.cast(product)
            if not design:
                continue

            doc_name    = sanitize(doc.name or 'Document')
            seen_bodies = set()

            for i in range(design.timeline.count):
                item    = design.timeline.item(i)
                entity  = item.entity
                extrude = adsk.fusion.ExtrudeFeature.cast(entity)

                if extrude:
                    # --- Circular extrude: dowel ---
                    if is_circular_profile(extrude):
                        export_dowel(extrude, doc_name, out_folder, design, i, exported, skipped)
                        continue

                    # --- Flat extrude ---
                    thickness_name = extrude_thickness(extrude)
                    if not thickness_name:
                        try:
                            raw      = extrude.extentOne.distance.value
                            dist_str = f'{raw:.4f}cm / {raw/2.54:.4f}in'
                        except Exception:
                            dist_str = 'unknown distance'
                        skipped.append(f'{doc_name} :: {extrude.name}  ({dist_str})')
                        continue

                    # Export each body individually: pick its largest planar face
                    # (the cut profile) and project only that face's edges.
                    for body in extrude.bodies:
                        token = body.entityToken
                        if token in seen_bodies:
                            continue
                        seen_bodies.add(token)

                        name = sanitize(body.name or f'Extrude{i}')
                        planar_faces = [f for f in body.faces
                                        if f.geometry.objectType == adsk.core.Plane.classType()]
                        if not planar_faces:
                            skipped.append(f'{doc_name} :: {name}  (no planar face)')
                            continue

                        face   = max(planar_faces, key=lambda f: f.area)
                        comp   = body.parentComponent
                        sketch = comp.sketches.add(face)
                        for edge in face.edges:
                            sketch.project(edge)
                        filename = f'sheet__{thickness_name}__{doc_name}__{name}.dxf'
                        filepath = os.path.join(out_folder, filename)
                        sketch.saveAsDXF(filepath)
                        sketch.deleteMe()
                        exported.append(filename)

                else:
                    # --- Non-extrude (copy, mirror, pattern, etc.) ---
                    bodies = get_feature_bodies(entity)
                    for body in bodies:
                        token = body.entityToken
                        if token in seen_bodies:
                            continue
                        seen_bodies.add(token)

                        match = find_sheet_face(body)
                        name  = sanitize(body.name or f'Body{i}')
                        if not match:
                            skipped.append(f'{doc_name} :: {name}  (no matching thickness face)')
                            continue

                        face, thickness_name = match
                        comp   = body.parentComponent
                        sketch = comp.sketches.add(face)
                        for edge in face.edges:
                            sketch.project(edge)
                        filename = f'sheet__{thickness_name}__{doc_name}__{name}.dxf'
                        filepath = os.path.join(out_folder, filename)
                        sketch.saveAsDXF(filepath)
                        sketch.deleteMe()
                        exported.append(filename)

        msg = f'Exported {len(exported)} DXF(s).\n'
        if skipped:
            msg += f'\nSkipped {len(skipped)}:\n'
            msg += '\n'.join(f'  • {s}' for s in skipped)
        ui.messageBox(msg)

    except Exception:
        ui.messageBox(f'Error:\n{traceback.format_exc()}')


def export_dowel(extrude, doc_name, out_folder, design, i, exported, skipped):
    try:
        prof_obj = extrude.profile
        profiles = [prof_obj.item(j) for j in range(prof_obj.count)] \
                   if hasattr(prof_obj, 'count') else [prof_obj]

        radius_cm = None
        for prof in profiles:
            try:
                loops = prof.profileLoops
                for k in range(loops.count):
                    curves = loops.item(k).profileCurves
                    if curves.count == 1:
                        geom = curves.item(0).geometry
                        if geom.objectType == adsk.core.Circle3D.classType():
                            radius_cm = geom.radius
                            break
            except Exception:
                pass
            if radius_cm:
                break

        # Fallback: read radius from the cylindrical face of the body
        if radius_cm is None:
            for body in extrude.bodies:
                for face in body.faces:
                    if face.geometry.objectType == adsk.core.Cylinder.classType():
                        radius_cm = face.geometry.radius
                        break
                if radius_cm:
                    break

        if radius_cm is None:
            bodies     = list(extrude.bodies)
            body_names = [sanitize(b.name) for b in bodies if b.name]
            base_label = sanitize(body_names[0]) if body_names else sanitize(extrude.name) or f'Dowel{i}'
            skipped.append(f'{doc_name} :: {base_label}  (dowel: could not determine radius)')
            return

        diameter_cm = radius_cm * 2
        length_cm   = abs(extrude.extentOne.distance.value)

        thickness_name = None
        for thickness_cm, tname in zip(THICKNESSES_CM, THICKNESS_NAMES):
            if abs(diameter_cm - thickness_cm) < TOLERANCE_CM:
                thickness_name = tname
                break

        bodies     = list(extrude.bodies)
        body_names = [sanitize(b.name) for b in bodies if b.name]
        base_label = sanitize(body_names[0]) if body_names else sanitize(extrude.name) or f'Dowel{i}'
        count      = len(bodies)
        label      = f'{base_label}__x{count}' if count > 1 else base_label

        if thickness_name is None:
            skipped.append(f'{doc_name} :: {base_label}  (dowel diameter {diameter_cm/2.54:.4f}in not a known thickness)')
            return

        sketch = design.rootComponent.sketches.add(design.rootComponent.xYConstructionPlane)
        sketch.sketchCurves.sketchLines.addTwoPointRectangle(
            adsk.core.Point3D.create(0, 0, 0),
            adsk.core.Point3D.create(diameter_cm, length_cm, 0)
        )
        filename = f'dowel__{thickness_name}__{doc_name}__{label}.dxf'
        filepath = os.path.join(out_folder, filename)
        sketch.saveAsDXF(filepath)
        sketch.deleteMe()
        exported.append(filename)

    except Exception:
        skipped.append(f'{doc_name} :: {extrude.name}  (dowel export error: {traceback.format_exc()})')


def is_circular_profile(extrude):
    try:
        for body in extrude.bodies:
            face_types  = [f.geometry.objectType for f in body.faces]
            cyl_count   = face_types.count(adsk.core.Cylinder.classType())
            plane_count = face_types.count(adsk.core.Plane.classType())
            if cyl_count == 1 and plane_count == 2 and len(face_types) == 3:
                return True
    except Exception:
        pass
    return False


def get_feature_bodies(entity):
    try:
        bodies = entity.bodies
        if bodies:
            return [bodies.item(j) for j in range(bodies.count)]
    except Exception:
        pass
    return []


def extrude_thickness(extrude):
    try:
        def dist_from_extent(extent):
            try:
                return abs(extent.distance.value)
            except Exception:
                return None

        d1 = dist_from_extent(extrude.extentOne)
        if d1 is None:
            return None

        d2         = dist_from_extent(extrude.extentTwo) or 0.0
        candidates = [d1, d1 * 2, d1 + d2]
        dist_cm    = next((c for c in candidates
                           if any(abs(c - t) < TOLERANCE_CM for t in THICKNESSES_CM)), None)
        if dist_cm is None:
            return None

        for thickness_cm, thickness_name in zip(THICKNESSES_CM, THICKNESS_NAMES):
            if abs(dist_cm - thickness_cm) < TOLERANCE_CM:
                return thickness_name

    except Exception:
        pass
    return None


def find_sheet_face(body):
    planar  = [f for f in body.faces
               if f.geometry.objectType == adsk.core.Plane.classType()]
    matches = []

    for i, fa in enumerate(planar):
        na = fa.geometry.normal
        oa = fa.geometry.origin
        for fb in planar[i+1:]:
            if abs(na.dotProduct(fb.geometry.normal) + 1.0) > 0.01:
                continue
            ob   = fb.geometry.origin
            diff = adsk.core.Vector3D.create(ob.x - oa.x, ob.y - oa.y, ob.z - oa.z)
            dist = abs(diff.dotProduct(na))
            for thickness_cm, thickness_name in zip(THICKNESSES_CM, THICKNESS_NAMES):
                if abs(dist - thickness_cm) < TOLERANCE_CM:
                    matches.append((dist, fa, thickness_name))

    if not matches:
        return None
    matches.sort(key=lambda m: m[0])
    return matches[0][1], matches[0][2]


def sanitize(name):
    return ''.join(c if c.isalnum() or c in '-_.' else '_' for c in str(name))
