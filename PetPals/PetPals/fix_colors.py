import os

directory = '/Users/seifateek/Downloads/PetPals/iOSapp/PetPals/PetPals'

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith('.swift') and file != 'Theme.swift':
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()
            
            new_content = content.replace('Color.white', 'Theme.cardBackground')
            new_content = new_content.replace('.background(.white)', '.background(Theme.cardBackground)')
            new_content = new_content.replace('.fill(.white)', '.fill(Theme.cardBackground)')
            
            if content != new_content:
                with open(filepath, 'w') as f:
                    f.write(new_content)
                print(f"Updated {filepath}")
