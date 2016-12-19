echo "Checking if Projects folder already exists"
if [ ! -d "$DIRECTORY" ]; then
  echo "Projects folder does not yet exists, creating..."
  mkdir ~/Projects
  echo "Projects folder created at ~/Projects"
fi
