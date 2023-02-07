# Get a list of all image files in the current directory
$images = Get-ChildItem -Path . -Filter *.{jpg,jpeg,png,gif} -File

# Set the starting number
$number = 1

# Loop over the list of images
foreach ($image in $images) {
  # Construct the new filename
  $new_filename = "IMG" + $number.ToString("D3") + $image.Extension
  # Rename the image file
  Rename-Item $image.FullName $new_filename
  # Increment the number
  $number++
}
