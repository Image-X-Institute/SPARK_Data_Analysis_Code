# -*- mode: python ; coding: utf-8 -*-

a = Analysis(
    ['GUI.py'],
    pathex=['.'],
    binaries=[],
    datas=[('dicom_anonymisation_rules_default.json', '.')],
    hiddenimports=[
        'pydicom',
        'pydicom.encoders.gdcm',
        'pydicom.encoders.pylibjpeg',
        'magic',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
)

pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name='DataAnonymisationTool',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
