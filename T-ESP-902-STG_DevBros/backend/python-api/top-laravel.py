import bpy
import mathutils
import os
import sys

# ========= CONFIG =========
# Valeurs par défaut pour ton .blend
REF_TSHIRT_NAME_DEFAULT = "REF_TSHIRT_STATIC"  # t-shirt de référence bien placé
MANNEQUIN_NAME_DEFAULT = "TOP"                 # mannequin pour les hauts

# Ajustements fins si besoin
FIT_XY_DEFAULT = 0.95       # 1.0 = même largeur que la réf, <1 = plus serré
FIT_Z_OFFSET_DEFAULT = 0.0  # décalage vertical en mètres (+ monte, - descend)

# On permet de surcharger via variables d'env pour s'adapter facilement
REF_TSHIRT_NAME = os.getenv("REF_TSHIRT_NAME", REF_TSHIRT_NAME_DEFAULT)
MANNEQUIN_NAME = os.getenv("MANNEQUIN_NAME", MANNEQUIN_NAME_DEFAULT)
FIT_XY = float(os.getenv("FIT_XY", FIT_XY_DEFAULT))
FIT_Z_OFFSET = float(os.getenv("FIT_Z_OFFSET", FIT_Z_OFFSET_DEFAULT))


# ========= UTILS =========
def get_world_bbox(obj):
    """Retourne (min, max) de la bounding box en coordonnées monde."""
    mat = obj.matrix_world
    coords = [mat @ mathutils.Vector(corner) for corner in obj.bound_box]
    min_c = mathutils.Vector(
        (
            min(v.x for v in coords),
            min(v.y for v in coords),
            min(v.z for v in coords),
        )
    )
    max_c = mathutils.Vector(
        (
            max(v.x for v in coords),
            max(v.y for v in coords),
            max(v.z for v in coords),
        )
    )
    return min_c, max_c


def safe_ratio(a, b):
    return a / b if b != 0 else 1.0


def find_imported_cloth(before_objects, exclude_names=None):
    """Retourne le mesh importé (différence entre avant/après import)."""
    if exclude_names is None:
        exclude_names = set()

    after_objects = set(bpy.data.objects)
    new_objs = [
        o
        for o in after_objects - before_objects
        if o.type == "MESH" and o.name not in exclude_names
    ]

    if not new_objs:
        raise RuntimeError("Aucun nouveau mesh vêtement trouvé après import GLB.")

    # S'il y en a plusieurs, on prend le plus gros (nb de vertices)
    new_objs.sort(key=lambda o: len(o.data.vertices), reverse=True)
    return new_objs[0]


# ========= ALIGNEMENT =========
def align_tshirt_to_ref(cloth, ref_obj):
    print("Alignement du vêtement sur la référence")

    # On s'assure d'être en Object Mode
    if bpy.ops.object.mode_set.poll():
        bpy.ops.object.mode_set(mode="OBJECT")

    bpy.context.view_layer.objects.active = cloth
    cloth.select_set(True)

    # Reset rotation/scale de l'import (on part propre)
    cloth.rotation_euler = (0.0, 0.0, 0.0)
    cloth.scale = (1.0, 1.0, 1.0)

    # BBox avant scale
    ref_min, ref_max = get_world_bbox(ref_obj)
    c_min, c_max = get_world_bbox(cloth)

    ref_size = ref_max - ref_min
    c_size = c_max - c_min

    # Ratios de taille
    sx = safe_ratio(ref_size.x, c_size.x)
    sy = safe_ratio(ref_size.y, c_size.y)
    sz = safe_ratio(ref_size.z, c_size.z)

    # Scale XY moyen + fitting
    s_xy = (sx + sy) * 0.5
    s_xy *= FIT_XY

    cloth.scale = (s_xy, s_xy, sz)

    # Recalcule les bbox après scale
    ref_min, ref_max = get_world_bbox(ref_obj)
    c_min, c_max = get_world_bbox(cloth)

    ref_center = (ref_min + ref_max) / 2.0
    cloth_center = (c_min + c_max) / 2.0

    # Offset pour aligner les centres
    offset = ref_center - cloth_center
    offset.z += FIT_Z_OFFSET  # petit ajustement vertical si besoin

    cloth.location += offset
    cloth.rotation_euler = ref_obj.rotation_euler.copy()

    print(f"Aligné : scale XY={s_xy:.3f}, Z={sz:.3f}, offset={offset}")


def prepare_with_mannequin(cloth, mannequin):
    """On affiche le bon mannequin et on parent le vêtement dessus."""
    # Cache les autres mannequins
    for obj in bpy.data.objects:
        if obj.name in ("TOP", "BOTTOM", "FULL"):
            obj.hide_set(obj.name != mannequin.name)

    # Parent simple (pas d'armature)
    cloth.parent = mannequin
    print(f"Parenté de {cloth.name} à {mannequin.name}")


def export_selection_as_glb(filepath, objs):
    """Exporte uniquement les objets passés en paramètre."""
    # Clear sélection
    for obj in bpy.data.objects:
        obj.select_set(False)

    for obj in objs:
        obj.select_set(True)

    # Active = mannequin
    bpy.context.view_layer.objects.active = objs[0]

    bpy.ops.export_scene.gltf(
        filepath=filepath,
        export_format="GLB",
        use_selection=True,
        export_apply=True,
    )
    print(f"Export GLB -> {filepath}")


# ========= MAIN =========
def process_tshirt(input_glb, output_glb):
    print("Import GLB vêtement :", input_glb)

    # Sauvegarde la liste d'objets avant import
    before_objects = set(bpy.data.objects)

    # Import du vêtement
    bpy.ops.import_scene.gltf(filepath=input_glb)

    # Récup mesh importé
    cloth = find_imported_cloth(
        before_objects,
        exclude_names={REF_TSHIRT_NAME, MANNEQUIN_NAME},
    )
    print(f"Vêtement importé détecté : {cloth.name}")

    # Récup réf
    ref_obj = bpy.data.objects.get(REF_TSHIRT_NAME)
    if ref_obj is None:
        raise RuntimeError(f"Objet de référence '{REF_TSHIRT_NAME}' introuvable.")

    # Récup mannequin
    mannequin = bpy.data.objects.get(MANNEQUIN_NAME)
    if mannequin is None:
        raise RuntimeError(f"Mannequin '{MANNEQUIN_NAME}' introuvable.")

    # Alignement + parent
    align_tshirt_to_ref(cloth, ref_obj)
    prepare_with_mannequin(cloth, mannequin)

    # Export uniquement mannequin + vêtement
    export_selection_as_glb(output_glb, [mannequin, cloth])

    print("\nFINI : T-shirt aligné et GLB exporté.\n")


if __name__ == "__main__":
    # Blender passe les arguments utilisateur après '--'
    argv = sys.argv
    if "--" not in argv:
        raise RuntimeError(
            "Usage: blender -b base.blend -P top-laravel.py -- input.glb output.glb\n"
            "ENV possibles : REF_TSHIRT_NAME, MANNEQUIN_NAME, FIT_XY, FIT_Z_OFFSET"
        )

    argv = argv[argv.index("--") + 1 :]
    if len(argv) != 2:
        raise RuntimeError("Il faut 2 arguments : input_glb output_glb")

    input_glb, output_glb = argv
    process_tshirt(input_glb, output_glb)

