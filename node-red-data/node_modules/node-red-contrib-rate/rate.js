/**
 * Copyright 2016 Dean Cording <dean@cording.id.au>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 **/

const util = require('util');

module.exports = function(RED) {
    "use strict";

    function RateNode(n) {
        RED.nodes.createNode(this,n);
        var node = this;

        node.name = n.name;
        node.inputField = n.inputField || "payload";
        node.inputFieldType = n.inputFieldType || "msg";
        node.outputField = n.outputField  || "rate";
        node.outputFieldType = n.outputFieldType || "msg";
        node.timestampField = n.timestampField || "timestamp";
        node.timestampFieldType = n.timestampFieldType || "now";
        node.ratePeriod = n.ratePeriod || 1000;  // Rate period in timestamp units

        node.previousValues = {};

        node.on("input", function(msg) {

            var timestamp;
            
            if (node.timestampFieldType == "now") {
                timestamp = Date.now();
            } else {
                timestamp = RED.util.evaluateNodeProperty(node.timestampField, node.timestampFieldType, node, msg);
            }
            
            var currentValue = RED.util.evaluateNodeProperty(node.inputField, node.inputFieldType, node, msg);

            var topic = RED.util.getMessageProperty(msg,"topic");

            var previous = node.previousValues[topic];

            if (previous === undefined) {
                node.previousValues[topic] = {};
            } else {

                var rate = node.ratePeriod * (currentValue - previous.value) / (timestamp - previous.timestamp);

                if (node.outputFieldType === 'msg') {
                    RED.util.setMessageProperty(msg,node.outputField,rate);
                } else if (node.outputFieldType === 'flow') {
                    node.context().flow.set(node.outputField,rate);
                } else if (node.outputFieldType === 'global') {
                    node.context().global.set(node.outputField,rate);
                }
            }

            node.previousValues[topic].value = currentValue;
            node.previousValues[topic].timestamp = timestamp;

            node.send(msg);

        });
    }

    RED.nodes.registerType("rate", RateNode);
}

