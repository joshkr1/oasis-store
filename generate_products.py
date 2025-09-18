import os

# Paths
template_file = "index.html"
output_file = "index.html"
images_dir = "images"

# Read the template
with open(template_file, "r") as f:
    template = f.read()

# Generate image HTML
image_tags = []
for img in os.listdir(images_dir):
    if img.lower().endswith((".png", ".jpg", ".jpeg", ".gif")):
        image_tags.append(f'<img src="images/{img}" alt="{img}">')

# Replace placeholder
html_output = template.replace("{{products}}", "\n      ".join(image_tags))

# Write updated file
with open(output_file, "w") as f:
    f.write(html_output)

print("✅ index.html updated with product images!")

