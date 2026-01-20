import shutil
import os

project_path = '/Users/yanzhe/workspace/Mathaxy/MathaxyAI/MathaxyAI-iOS/Mathaxy.xcodeproj/project.pbxproj'
backup_path = project_path + '.backup_v3'

# 1. Backup
if not os.path.exists(backup_path):
    shutil.copy(project_path, backup_path)
    print(f"Backed up project file to {backup_path}")

with open(project_path, 'r') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    new_lines.append(line)
    if 'GENERATE_INFOPLIST_FILE = YES;' in line:
        # Check if INFOPLIST_FILE is already set in the next few lines (basic check)
        # Assuming standard formatting, we just insert it.
        # Indentation should match the current line
        indent = line[:line.find('GENERATE_INFOPLIST_FILE')]
        new_lines.append(f'{indent}INFOPLIST_FILE = Mathaxy/App-Info.plist;\n')

with open(project_path, 'w') as f:
    f.writelines(new_lines)

print("Project file updated: Added INFOPLIST_FILE setting.")
