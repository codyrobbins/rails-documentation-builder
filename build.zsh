# Use RVM.
source ~/.rvm/scripts/rvm

# Install gems.
bundle install

# Check out the Rails repository.
if [[ ! -e rails ]]; then
  git clone git://github.com/rails/rails.git
fi

# Create the output directory.
mkdir -p output

# Fetch new tags.
cd rails

git checkout master
git fetch --tags
git pull

# For each tag...
for tag in `git tag`; do
  version=${tag:1}
  directory=output/$version

  # If documentation hasn't already been generated for this tag...
  if [[ ! -e ../$directory ]]; then
    # Check out the tag.
    git checkout $tag

    # Figure out which readme to use as this version's main file.
    if [[ -e README.rdoc ]]; then
      main=README.rdoc
    elif [[ -e railties/RDOC_MAIN.rdoc ]]; then
      main=railties/RDOC_MAIN.rdoc
    elif [[ -e railties/README.rdoc ]]; then
      main=railties/README.rdoc
    elif [[ -e railties/README ]]; then
      main=railties/README
    fi

    cd ..

    # Generate the documentation.
    sdoc --output $directory --exclude '.*/test/.*' --exclude '.*/examples/.*' --exclude '.*/guides/.*' --main rails/$main --title "Ruby on Rails $version Documentation" rails

    # If a Google Analytics tracking code was specified...
    if [[ -n $GOOGLE_ANALYTICS ]]; then
      # Add it to every HTML file generated.
      find $directory/{classes,files} -name '*.html' | xargs sed -i '' -e "s%</head>%<script type=\"text/javascript\">var _gaq = _gaq || []; _gaq.push(['_setAccount', '$GOOGLE_ANALYTICS']); _gaq.push(['_trackPageview']); (function() { var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true; ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js'; var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s); })();</script></head>%"
    fi

    # If gzipping is enabled...
    if [[ -n $GZIP ]]; then
      # Gzip all files.
      find -E $directory -regex '.+\.(css|html|js)$' | xargs gzip

      # Remove the .gz extension.
      find -E $directory -regex '.+\.(css|html|js)\.gz$' | sed -E 's/(.+)\.gz$/& \1/' | xargs -L 1 mv
    fi

    # Go back to master.
    cd rails
    git checkout master
  fi
done