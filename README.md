Lonely Planet Programming Test
=======================
## Specification
Read the full specification [here](docs/introduction.pdf)

The short version is this program is a batch processor for generating HTML documents describing different location around the world.

These are generated from two XML files:
 * a taxonomy file describing the relationship between locations (i.e. state and city with the state)
 * a content file that provides information about the individual locations in the taxonomy file

These file are output to a directory specified by the user.

## Setup
You need to have bundler in your gemset which you can get by running ```gem install bundler```.

Then run ```bundle install``` to install the required gems for the project.

## Usage

The executable is located in ./bin/batch_process_destinations.rb and can be run with the following invocation:

```./bin/batch_process_destinations.rb <taxonomy file> <content file> <output directory>```

## Testing
Tests are written in rspec and are located in ./spec and can be ran with ```bundle exec rspec spec```

## Performance
Without a full data set it was hard to get an accurate assessment of the end performance of this program. That being said some basic profiling was done and a projection was done on based on a linear progression (i.e 30000 records will take roughly the same time as processing 24 records 1250 times). Whilst the linear progression is not accurate it does give a ball park indication on how it will perform under stress.

Processing the 24 records 1250 times finished in roughly 80 seconds. After running this with a profiler (ruby-prof), it was discovered that most of the bottle neck was in Nokogiri. A lot of the enumeration methods seemed to be fair less efficient than the standard ruby counterparts. The Node access methods were also reasonable slow. This could be improved by using a SAX parser. This would be more efficient from a memory perspective as well as a computational one as it would generate the relevant objects on the fly rather than parsing them from a document. That being said it would also have greater readability, complexity and maintainability costs than the current solution. Assuming this task is not going to be run hugely frequently (i.e once every 10 minutes), which seemed like a reasonable assumption give the nature of the task, a slightly slower but simpler, more readable and maintainable solution seemed the better way to go.

