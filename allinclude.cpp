#include <iostream>
#include <string>
#include <filesystem>
#include <exception>

#include "simple/file.hpp"
#include "simple/support/algorithm.hpp"

namespace fs = std::filesystem;
using namespace simple::file;
using namespace simple::support;

const char * exclude_filename = ".allinclude_exclude";

void generate_allinclude(fs::path directory, const std::vector<fs::path>& excluded_headers = {})
{
	std::cout << "generating allinclude files under: " << directory << '\n';
	auto i = fs::directory_iterator(directory);
	std::vector<fs::directory_entry> next_targets;
	for(auto&& subdir : i)
		if(subdir.is_directory())
		{
			std::cout << "for subdirectory: " << subdir << '\n';
			auto inc_file_path = fs::path(subdir.path()).replace_extension(".hpp").native();
			std::cout << "creating: " << inc_file_path << '\n';
			auto include_file = wopex(inc_file_path);
			auto i = fs::directory_iterator(subdir);
			for(auto&& entry : i)
			{
				fs::path include;
				if(entry.is_directory())
				{
					include = fs::path(entry.path()).replace_extension(".hpp");
				}
				else if(entry.path().extension() == ".hpp" || entry.path().extension() == ".h")
				{
					include = entry.path();
				}

				if(!include.empty() &&
					none_of(excluded_headers, [&](auto& p){return equivalent(p, include);}))
				{
					auto relative = fs::relative(include, directory);
					std::cout << "including: " << entry << " as " << relative << '\n';
					include_file << "#include \"" << relative.native() << "\"\n";
				}
			}
			next_targets.push_back(subdir);
		}

	for(auto&& target : next_targets)
		generate_allinclude(target, excluded_headers);
}

void clear_allinclude(fs::path directory)
{
	std::cout << "clearing existing allinclude files under: " << directory << '\n';
	auto i = fs::directory_iterator(directory);
	std::vector<fs::directory_entry> next_targets;
	for(auto&& subdir : i)
		if(subdir.is_directory())
		{
			next_targets.push_back(subdir);
		}

	for(auto&& subdir : next_targets)
	{
		std::cout << "for subdirectory: " << subdir << '\n';
		auto inc_file_path = fs::path(subdir.path()).replace_extension(".hpp");
		if(fs::remove(inc_file_path))
			std::cout << "removed: " << inc_file_path << '\n';
	}

	for(auto&& target : next_targets)
		clear_allinclude(target);
}

int main(int argc, char const* argv[]) try
{

	fs::path target = fs::current_path();
	if(argc > 1)
		target = argv[1];

	if(!fs::is_directory(target))
	{
		std::cerr << "Specified path is not a directory!" << '\n';
		return -1;
	}

	std::vector<fs::path> excluded_headers;
	for(int i = 2; i < argc; ++i)
		excluded_headers.emplace_back(argv[i]);

	if(fs::exists(exclude_filename))
	{
		auto exclude_file = ropen(exclude_filename);
		string line;
		while(std::getline(exclude_file, line))
			excluded_headers.emplace_back(line);
	}

	clear_allinclude(target);
	std::cout << '\n';
	generate_allinclude(target, excluded_headers);
}
catch(const std::exception& ex)
{
	if(errno)
		std::perror("Error: ");

	std::cerr << "Exception: " << ex.what() << '\n';
}
