module.exports = function (RED) {
	'use strict'

	function delta (x, y) {
		if (typeof x === 'string')
			x = parseFloat(x)
		if (typeof y === 'string')
			y = parseFloat(y)
		if (typeof x === 'number' && typeof y === 'number')
			return y - x
		if (Array.isArray(x) && Array.isArray(y)) {
			var result = []
			var len = Math.min(x.length, y.length)
			for (var i = 0; i < len; i++)
				result.push(delta(x[i], y[i]))
			return result
		}
		if (typeof x === 'object' && typeof y === 'object') {
			var result = {}
			Object.keys(y).forEach(function (k) {
				result[k] = delta(x[k], y[k])
			})
			return result
		}
		return null
	}

	function DeltaNode (config) {
		RED.nodes.createNode(this, config)
		var node = this

		node.last = null

		this.on('input', function (msg) {
			var data = msg.payload
			if (node.last === null) {
				node.last = data
				return
			}
			var result = delta(node.last, data)
			node.last = data
			node.send({ payload: result })
		})

	}

	RED.nodes.registerType('delta', DeltaNode)
}
