import os

def batch_rename_png(directory):
    png_files = [f for f in os.listdir(directory) if f.lower().endswith('.png')]
    png_files.sort()
    for index, filename in enumerate(png_files, start=1):
        name, ext = os.path.splitext(filename)
        new_name = f"{index}_{name}{ext}"
        os.rename(os.path.join(directory, filename), os.path.join(directory, new_name))
    print(f"Renamed {len(png_files)} files.")

if __name__ == "__main__":
    current_dir = os.path.dirname(os.path.abspath(__file__))
    batch_rename_png(current_dir)
