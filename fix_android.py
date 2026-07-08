import re

with open("android/app/build.gradle.kts", "r") as f:
    c = f.read()

# Fix NDK version
c = c.replace('ndkVersion = flutter.ndkVersion', 'ndkVersion = "27.0.12077973"')

# Enable core library desugaring
c = c.replace('compileOptions {', 'compileOptions {\n    isCoreLibraryDesugaringEnabled = true')

# Add dependencies block
if "coreLibraryDesugaring" not in c:
    c += '\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n}\n'

with open("android/app/build.gradle.kts", "w") as f:
    f.write(c)

print("=== Patched build.gradle.kts ===")
print(open("android/app/build.gradle.kts").read())
