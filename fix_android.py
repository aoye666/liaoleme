import re
import os

with open("android/app/build.gradle.kts", "r") as f:
    c = f.read()

# Fix NDK version
c = c.replace('ndkVersion = flutter.ndkVersion', 'ndkVersion = "27.0.12077973"')

# Enable core library desugaring
c = c.replace('compileOptions {', 'compileOptions {\n    isCoreLibraryDesugaringEnabled = true')

# Add signing configs - use fixed keystore to avoid signature conflicts
# This must be inside android { } block
signing_block = '''
    signingConfigs {
        create("release") {
            storeFile = file(System.getenv("KEYSTORE_PATH") ?: "liaoleme.jks")
            storePassword = System.getenv("KEYSTORE_PASSWORD") ?: ""
            keyAlias = System.getenv("KEY_ALIAS") ?: ""
            keyPassword = System.getenv("KEY_PASSWORD") ?: ""
        }
    }
'''

# Insert signingConfigs inside android { } block
# Find the android { block and insert after the opening brace
pattern = r'(android\s*\{)'
match = re.search(pattern, c)
if match and "signingConfigs" not in c:
    insert_pos = match.end()
    c = c[:insert_pos] + signing_block + c[insert_pos:]

# Fix release build type to use our signing config
# Default is: signingConfig = signingConfigs.getByName("debug")
# Change to: signingConfig = signingConfigs.getByName("release")
c = c.replace(
    'signingConfig = signingConfigs.getByName("debug")',
    'signingConfig = signingConfigs.getByName("release")'
)

# Also fix the debug build type to use our keystore too
# Add: debug { signingConfig = signingConfigs.getByName("release") }
debug_pattern = r'(getByName\("debug"\)\s*\{)'
def add_debug_signing(match):
    return match.group(1) + '\n            signingConfig = signingConfigs.getByName("release")'
c = re.sub(debug_pattern, add_debug_signing, c)

# Add dependencies block
if "coreLibraryDesugaring" not in c:
    c += '\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n}\n'

# Remove the isMinifyEnabled line if present (can cause issues in some setups)
c = c.replace('isMinifyEnabled = true', 'isMinifyEnabled = false')

with open("android/app/build.gradle.kts", "w") as f:
    f.write(c)

print("=== Patched build.gradle.kts ===")
print(open("android/app/build.gradle.kts").read())
