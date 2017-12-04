class text
	nbs = "\u00A0"

	@spaces: (noOfSpaces) ->
		return _.pad("", Math.max(0, noOfSpaces), nbs)

	@indent: (noOfSpaces, text) ->
		return "#{@spaces(noOfSpaces)}#{text.toString()}"

	@align: (lcr, length, text) ->		# align text left, center or right
		str = text.toString()
		center =  Math.trunc((length - str.length) / 2)
		right = length - str.length
		spacesLeft = [0, center, right][["l", "c", "r"].indexOf(lcr)]
		return "#{@spaces(spacesLeft)}#{str}#{@spaces(length - str.length - spacesLeft)}".slice(0, length)

	@key: (length, key, value) ->
		keyStr = key.toString()
		valueStr = value.toString()
		valueAligned = @indent(length - keyStr.length - valueStr.length, valueStr)
		return "#{keyStr}#{valueAligned}".slice(0, length)

	@arrayToTable: (array, isPad, columnAlign, columnMaxWidth) -> # construct a table from an 2 dim array. Returns an 1 dim array, elements are the table rows
		vl = "\u2502"
		maxWidths = []
		for col in [0..array[0].length - 1]
			maxWidths.push(array[0][col].toString().length)
			for row in [0..array.length - 1]
				maxWidths[col] = Math.max(maxWidths[col], array[row][col].toString().length)
			maxWidths[col] = Math.min(maxWidths[col], columnMaxWidth[col]) if columnMaxWidth? && col < columnMaxWidth.length

		table = []
		pad  = isPad && nbs || ""
		for row in [0..array.length - 1]
			table.push(vl)
			for col in [0..array[0].length - 1]
				align = columnAlign? && col < columnAlign.length && columnAlign[col] || "c"
				table[row] += "#{pad}#{text.align(align, maxWidths[col], array[row][col].toString())}#{pad}#{vl}"
		return table


handle: ->
    storage.init ?= _.once ->
        debug "12345567890123456"
        debug text.indent(4, "Text indented with 4 spaces")
        info text.align("c", 18, "TITLE")
        debug "|" + text.align("l", 16, "left") + "|"
        warn "|#{text.align("c", 16, "center")}|"
        debug "|#{text.align("r", 16, "right")}|"
        debug "|#{text.align("c", 16, "A long string is truncated")}|"
        
        
        debug " "
        # Example: keys 
        debug text.key(5, "a:", "4")
        debug text.key(5, "b:", "40")
        debug text.key(5, "b:", "400")
        
        # another align example
        s = "*"
        for i in [0..30]
            debug text.align("c", 35, s)
            s =  i < 15 && s+"**" || s.slice(0, s.length - 2)
            
        # Example: table 
        array = []
        array.push(["column 1", "column 2", "colum 3", "column4"])
        array.push(["value 1", 2, 3, 4])
        array.push(["value 2", 200, 300, 400])

        debug " "
        # default column aligment 
        table = text.arrayToTable(array)
        debug row for row in table
        
        debug " "
        #  custom column alignement
        withPadding = true
        table = text.arrayToTable(array, withPadding, ["c", "c", "r", "l"])
        debug row for row in table
        

    storage.init()
