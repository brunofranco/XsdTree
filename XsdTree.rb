require 'nokogiri'

class CdmTree

	$complexTypes = Hash.new
	$element
	$padding = ""
	$annotation = ""
	$out = File.new("out.txt", "w")

	def addChilds(node, padding)

		if node == nil
			return
		end

		if node.name == "element"
			#$out.puts "AddOutElement " + node['type'].split(":")[1]
			#$out.puts node.children
			addChilds(node.children[0], padding)
			addChilds($complexTypes[node['type'].split(":")[1]], padding)
			return
		end
#$out.puts node.children.size
		node.children.each do |child|
			# if child['name'] != nil
			# 	$out.puts padding + "Child " + child['name']
			# end
			# if child['base'] != nil
			# 	$out.puts padding + "Child " + child['base']
			# end

			if child.name == "documentation"
				$annotation = child.content
			end

			if child.name == "extension"
				$out.puts padding + child['base'].split(":")[1]
				addChilds($complexTypes[child['base'].split(":")[1]], padding + '  ')
			end

			if child.name == "element"
				printElement(child, padding)
				addChilds($complexTypes[child['type'].split(":")[1]], padding + '  ')
				next
			end

			# if child['name'] != nil
			# 	$out.puts padding + "AddDefault " + child['name']
			# end
			# if child['base'] != nil
			# 	$out.puts padding + "AddDefault " + child['base']
			# end

			addChilds(child, padding)
		end
	end

	def printElement(element, padding)
		@param = ""
		@max = ""
		@min = ""
		if element['maxOccurs'] != nil
			@max = element['maxOccurs']
		end
		if element['minOccurs'] != nil
			@min = element['minOccurs']
		end

		$out.puts  $annotation
		$out.print padding + element['name'] + "    [" + @min + " - " + @max + "]   "
		$annotation = ""

	end

	def addNodes(file)

		f = File.open(file)
			@doc = Nokogiri::XML(f)
			@doc.root.children.each do |node|
				if node.name == "complexType"
					$complexTypes[node['name']] = node
				end
				if node.name == "element"
					$element = node
				end
			end
		f.close		
	end

	if __FILE__ == $0

		cdmTree = CdmTree.new

		@directory = Dir.pwd + "/"
		@file = @directory + ARGV[0]

		cdmTree.addNodes(@file)
		if File.exists?(@directory+"common.xsd")
			cdmTree.addNodes(@directory+"common.xsd")
		end

		$out.puts $element['name']
		cdmTree.addChilds($element, ' ')

		$out.close

		file = File.new(@file.gsub("\.xsd","\.txt"), "w")

		File.foreach("out.txt") { |line|
			file.puts line unless line.chomp.empty?
		}
		
		File.delete($out)
	end

end