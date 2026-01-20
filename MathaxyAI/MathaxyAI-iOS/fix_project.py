import re
import shutil
import os

project_path = '/Users/yanzhe/workspace/Mathaxy/MathaxyAI/MathaxyAI-iOS/Mathaxy.xcodeproj/project.pbxproj'
backup_path = project_path + '.backup'

# 1. Backup the project file
if not os.path.exists(backup_path):
    shutil.copy(project_path, backup_path)
    print(f"Backed up project file to {backup_path}")

with open(project_path, 'r') as f:
    content = f.read()

# 2. Find Info.plist file reference ID
# Pattern: 34A... /* Info.plist */ = {isa = PBXFileReference; ... path = Info.plist; ... };
info_plist_ref_pattern = re.compile(r'([0-9A-F]{24})\s/\*\sInfo.plist\s\*/\s=\s\{isa\s=\sPBXFileReference')
match = info_plist_ref_pattern.search(content)

if not match:
    print("Could not find Info.plist file reference. It might not be in the project.")
    # Attempt to find by path if comment is missing or different
    info_plist_path_pattern = re.compile(r'([0-9A-F]{24})\s/\*.*?\*/\s=\s\{isa\s=\sPBXFileReference;.*?path\s=\sInfo.plist;')
    match = info_plist_path_pattern.search(content)

if match:
    file_id = match.group(1)
    print(f"Found Info.plist file ID: {file_id}")
    
    # 3. Find PBXResourcesBuildPhase
    # We need to find the section that contains "isa = PBXResourcesBuildPhase" and remove the line containing the file_id
    
    # This is a bit complex because the file ID in BuildPhase is different (it's a BuildFile ID, not FileReference ID)
    # So first we need to find the PBXBuildFile that refers to this FileReference
    
    # Pattern: 34B... /* Info.plist in Resources */ = {isa = PBXBuildFile; fileRef = 34A... /* Info.plist */; };
    build_file_pattern = re.compile(r'([0-9A-F]{24})\s/\*\sInfo.plist\sin\sResources\s\*/\s=\s\{isa\s=\sPBXBuildFile;\sfileRef\s=\s' + file_id)
    build_file_match = build_file_pattern.search(content)
    
    if build_file_match:
        build_file_id = build_file_match.group(1)
        print(f"Found PBXBuildFile ID for Info.plist: {build_file_id}")
        
        # Now remove the PBXBuildFile definition
        # It looks like: 34B... /* Info.plist in Resources */ = {isa = PBXBuildFile; fileRef = 34A... /* Info.plist */; };
        # We'll use regex to remove this line
        content = re.sub(r'\s+' + build_file_id + r'.*?isa\s=\sPBXBuildFile.*?;', '', content, flags=re.DOTALL)
        
        # Now remove the reference from PBXResourcesBuildPhase
        # The section looks like:
        # isa = PBXResourcesBuildPhase;
        # files = (
        #    34B... /* Info.plist in Resources */,
        # );
        
        # We can just remove the line containing the build_file_id
        content = re.sub(r'\s+' + build_file_id + r'.*?/\*\sInfo.plist\sin\sResources\s\*/,', '', content)
        
        print("Removed Info.plist from PBXResourcesBuildPhase and PBXBuildFile section.")
        
        with open(project_path, 'w') as f:
            f.write(content)
        print("Project file updated successfully.")
        
    else:
        print("Could not find PBXBuildFile for Info.plist. It might not be in any build phase (which is good), or named differently.")
        # Fallback: search for any usage of file_id in PBXBuildFile
        fallback_pattern = re.compile(r'([0-9A-F]{24})\s/\*.*?\*/\s=\s\{isa\s=\sPBXBuildFile;\sfileRef\s=\s' + file_id)
        fallback_match = fallback_pattern.search(content)
        if fallback_match:
            build_file_id = fallback_match.group(1)
            print(f"Found generic PBXBuildFile ID: {build_file_id}")
            # Remove definition
            content = re.sub(r'\s+' + build_file_id + r'.*?isa\s=\sPBXBuildFile.*?;', '', content, flags=re.DOTALL)
            # Remove reference
            content = re.sub(r'\s+' + build_file_id + r'.*?,', '', content)
             
            with open(project_path, 'w') as f:
                f.write(content)
            print("Project file updated successfully (fallback method).")
        else:
            print("Info.plist is not linked in any build phase. No changes needed.")

else:
    print("Could not find Info.plist file reference in project.")
