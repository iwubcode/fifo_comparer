# Compares two dolphin exes with some fifologs
# Takes the following input
#  Dolphin directory 1 (a directory with Dolphin.exe in it)
#  Dolphin directory 2 (a second directory with Dolphin.exe in it)
#  A directory where one or more fifologs are
#  A folder where 'imagemagick' is located (the exe magick)
 
require 'fileutils'
require 'open3'

class FifoComparer
	def initialize(dolphin_dir_1, dolphin_dir_2, fifo_log_dir, magick_folder)
		@backends = ["D3D", "OGL", "Vulkan"]
		@dolphin_dirs = [] << dolphin_dir_1 << dolphin_dir_2
		@directories_to_ignore = ["..", "."]
		puts "#{fifo_log_dir}"
		puts "#{File.join(fifo_log_dir, "*.dff")}"
		@fifo_files = Dir.glob(File.join(fifo_log_dir, "*.dff"))
		@magick_folder = magick_folder
		@config_location = File.join(get_root, "Config")
	end

	def run
		@dolphin_dirs.each do |dolphin_dir|
			FileUtils.rm_rf(File.join(dolphin_dir, "User"))
			
			dolphin_config_dir = File.join(dolphin_dir, "User", "Config")
			FileUtils.mkdir_p(dolphin_config_dir)
			FileUtils.mkdir_p(File.join(dolphin_dir, "User", "Dump", "Frames"))
			Dir.glob(File.join(@config_location, "*.ini")) do |config_file|
				FileUtils.cp(config_file, dolphin_config_dir)
			end
			
			FileUtils.touch(File.join(dolphin_dir, "portable.txt"))
		end
		
		@fifo_files.each do |fifo_path|
			fifo_file_name = File.basename(fifo_path, "*.dff")
			capture_fifo_log_results(fifo_file_name, fifo_path)
			create_comparisons(fifo_file_name)
		end
	end

	def capture_fifo_log_results(fifo_name, fifo_full_path)
		puts "Capturing for fifo: #{fifo_name}"
		@backends.each do |backend|
			@dolphin_dirs.each do |dolphin_dir|
				dolphin_program = File.join(dolphin_dir, "Dolphin")
				`#{dolphin_program} -b -e #{fifo_full_path} -v #{backend}`
				
				dump_location = File.join(dolphin_dir, "User", "Dump", "Frames")
				results_dir = File.join(get_root, "Results", fifo_name, backend, File.basename(dolphin_dir))
				FileUtils.mkdir_p(results_dir)
				
				Dir.glob(File.join(dump_location, "*.png")) do |frameimage|
					FileUtils.mv(frameimage, results_dir)
				end
			end
		end
	end
	
	def create_comparisons(fifo_name)
		@backends.each do |backend|
			first_dir = File.join(get_root, "Results", fifo_name, backend, File.basename(@dolphin_dirs[0]))
			second_dir = File.join(get_root, "Results", fifo_name, backend, File.basename(@dolphin_dirs[1]))
			
			pngs_in_first_dir = Dir.glob(File.join(first_dir, "*.png"))
			pngs_in_second_dir = Dir.glob(File.join(second_dir, "*.png"))
			
			if (pngs_in_first_dir.size != pngs_in_second_dir.size)
				raise "Result directories do not have the same amount of files!"
			end
			
			comparison_dir = File.join(get_root, "Comparisons", fifo_name, backend)
			FileUtils.mkdir_p(comparison_dir)
		
			pngs_in_first_dir.each do |file|
				file_name = File.basename(file)
				
				image_comparison_cmd = "#{File.join(@magick_folder, "magick")} compare -metric ae #{File.join(first_dir, file_name)} #{File.join(second_dir, file_name)} null:"
				Open3.popen3(image_comparison_cmd) do |stdin, stdout, stderr, wait_thr|
					pixel_count = stderr.read.to_i
					if (pixel_count > 0)
						puts "Found difference for image '#{file_name}' using fifo log '#{fifo_name}' on backend '#{backend}'"
						`#{File.join(@magick_folder, "magick")} composite #{File.join(first_dir, file_name)} #{File.join(second_dir, file_name)} -compose difference #{File.join(comparison_dir, file_name)} `
					end
				end
			end
		end
	end
	
	def get_root
	  File.expand_path(File.dirname(__FILE__))
	end
end

FifoComparer.new(ARGV[0], ARGV[1], ARGV[2], ARGV[3]).run
