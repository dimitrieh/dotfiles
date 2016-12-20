echo "Checking if Projects folder already exists"
if [ ! -d ~/Projects ]; then
  echo "Projects folder does not yet exists, creating..."
  mkdir ~/Projects
  echo "Projects folder created at ~/Projects"
else
  echo "Projects folder already exists"
fi
