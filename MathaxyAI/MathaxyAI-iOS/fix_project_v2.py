import re
import shutil
import os

project_path = '/Users/yanzhe/workspace/Mathaxy/MathaxyAI/MathaxyAI-iOS/Mathaxy.xcodeproj/project.pbxproj'
backup_path = project_path + '.backup_v2'

# 1. Backup the project file
if not os.path.exists(backup_path):
    shutil.copy(project_path, backup_path)
    print(f"Backed up project file to {backup_path}")

with open(project_path, 'r') as f:
    content = f.read()

# Strategy:
# 1. Find all file references that point to "Info.plist"
# 2. For each file reference, find if it's used in a PBXBuildFile
# 3. If used in a PBXBuildFile, check if that build file is in PBXResourcesBuildPhase
# 4. If so, remove it.

# Step 1: Find File References for Info.plist
# Pattern: 34A... /* Info.plist */ = {isa = PBXFileReference; ... path = Info.plist; ... };
# We look for 'path = Info.plist' or similar
file_refs = []
# Match: ID /* Comment */ = { ... path = Info.plist ... }
# Note: path value might be quoted or not
file_ref_regex = re.compile(r'([0-9A-F]{24})\s/\*.*?\*/\s=\s\{.*?isa\s=\sPBXFileReference;.*?path\s=\s"?Info\.plist"?;', re.DOTALL)

for match in file_ref_regex.finditer(content):
    file_id = match.group(1)
    print(f"Found Info.plist FileReference ID: {file_id}")
    file_refs.append(file_id)

if not file_refs:
    print("No Info.plist FileReference found in project.pbxproj via regex.")
    # Try simpler search
    if "Info.plist" in content:
        print("String 'Info.plist' found in file, but regex failed. Dumping context...")
        idx = content.find("Info.plist")
        print(content[max(0, idx-100):min(len(content), idx+100)])
    else:
        print("String 'Info.plist' NOT found in file.")

# Step 2 & 3: Find usage in Build Phases
changes_made = False

for file_id in file_refs:
    # Find PBXBuildFile using this file_ref
    # Pattern: ID /* ... */ = {isa = PBXBuildFile; fileRef = FILE_ID ... }
    build_file_regex = re.compile(r'([0-9A-F]{24})\s/\*.*?\*/\s=\s\{isa\s=\sPBXBuildFile;\sfileRef\s=\s' + file_id)
    
    for bf_match in build_file_regex.finditer(content):
        build_file_id = bf_match.group(1)
        print(f"Found PBXBuildFile ID: {build_file_id} for FileRef: {file_id}")
        
        # Check if this build file is in Resources Build Phase
        # Resources phase looks like:
        # isa = PBXResourcesBuildPhase;
        # ...
        # files = (
        #    ID /* ... */,
        # );
        
        # We search for the Resources phase section
        resources_phase_regex = re.compile(r'isa\s=\sPBXResourcesBuildPhase;.*?files\s=\s\((.*?)\);', re.DOTALL)
        
        for rp_match in resources_phase_regex.finditer(content):
            files_block = rp_match.group(1)
            if build_file_id in files_block:
                print(f"Found BuildFile {build_file_id} in a PBXResourcesBuildPhase. Removing it...")
                
                # Remove the line from files list
                # The line format is usually: ID /* Comment */,
                # We'll use a specific regex for the files block replacement
                
                # Construct regex to match the line with this ID in the files block
                line_regex = re.compile(r'\s+' + build_file_id + r'.*?,')
                
                # We need to replace in the specific section we found, but since we're modifying 'content',
                # and IDs are unique, we can just remove the reference line globally from the file content if we are careful.
                # However, to be safe, let's remove the BuildFile definition AND the reference.
                
                # 1. Remove reference from files list
                content = re.sub(r'\s+' + build_file_id + r'.*?,', '', content)
                
                # 2. Remove BuildFile definition
                content = re.sub(r'\s+' + build_file_id + r'.*?isa\s=\sPBXBuildFile.*?;', '', content, flags=re.DOTALL)
                
                changes_made = True
                print("Removal complete.")

if changes_made:
    with open(project_path, 'w') as f:
        f.write(content)
    print("Successfully updated project.pbxproj")
else:
    print("No changes made. Info.plist might not be in the Copy Bundle Resources phase.")
