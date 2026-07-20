import re
import os

with open("android/app/build.gradle.kts", "r") as f:
    content = f.read()

print("=== ORIGINAL (first 80 lines) ===")
for i, line in enumerate(content.split('\n')[:80], 1):
    print(f"{i:3}: {line}")

# Fix NDK version
content = content.replace('ndkVersion = flutter.ndkVersion', 'ndkVersion = "27.0.12077973"')

# Enable core library desugaring
content = content.replace('compileOptions {', 'compileOptions {\n    isCoreLibraryDesugaringEnabled = true')

# Strategy: Insert signingConfigs block AND fix references in one pass
# The trick: add signingConfigs block right before "buildTypes {" line
signing_block = """    signingConfigs {
        create("release") {
            storeFile = file(System.getenv("KEYSTORE_PATH") ?: "liaoleme.jks")
            storePassword = System.getenv("KEYSTORE_PASSWORD") ?: ""
            keyAlias = System.getenv("KEY_ALIAS") ?: ""
            keyPassword = System.getenv("KEY_PASSWORD") ?: ""
        }
    }

"""

# Insert before "buildTypes {"
content = content.replace('\n    buildTypes {\n', '\n' + signing_block + '    buildTypes {\n')

# Now fix the signingConfig reference: replace "debug" with "release"
content = content.replace(
    'signingConfig = signingConfigs.getByName("debug")',
    'signingConfig = signingConfigs.getByName("release")'
)

# Add debug build type if not present
if 'getByName("debug")' not in content:
    content = content.replace(
        'release {\n            signingConfig = signingConfigs.getByName("release")\n        }',
        'release {\n            signingConfig = signingConfigs.getByName("release")\n        }\n        debug {\n            signingConfig = signingConfigs.getByName("release")\n        }'
    )

# Add dependencies block
if "coreLibraryDesugaring" not in content:
    content += '\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n}\n'

# Remove isMinifyEnabled if present
content = content.replace('isMinifyEnabled = true', 'isMinifyEnabled = false')

with open("android/app/build.gradle.kts", "w") as f:
    f.write(content)

print("\n=== Patched build.gradle.kts ===")
print(open("android/app/build.gradle.kts").read())

# Fix AndroidManifest.xml to set correct app name
manifest_path = "android/app/src/main/AndroidManifest.xml"
if os.path.exists(manifest_path):
    with open(manifest_path, "r") as f:
        manifest = f.read()

    # Replace android:label value with correct app name
    manifest = re.sub(
        r'android:label="[^"]*"',
        'android:label="录了么"',
        manifest
    )

    with open(manifest_path, "w") as f:
        f.write(manifest)

    print("\n=== Patched AndroidManifest.xml ===")
    print(open(manifest_path).read())
