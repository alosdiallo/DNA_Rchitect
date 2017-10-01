//Use jQuery to get data.json file

$.getJSON("data.json", function(data) {
          
          var cy = cytoscape({
                             container: document.getElementById('cy'),
                             elements: [],
                             style: [
                                     {
                                     selector: 'node',
                                     style: {
                                     shape: 'hexagon',
                                     'background-color': 'red',
                                     label: 'data(id)'
                                     }
                                     }]
                             });
          
          // build nodes
          for(var i in data){
          
          // add nodes from each line
          cy.add({
                 data: { id: data[i].node1 }
                 });
          cy.add({
                 data: { id: data[i].node2 }
                 });
          
          // add edge between those 2 nodes
          cy.add({
                 data: {
                 id: data[i].edge,
                 source: data[i].node1,
                 target: data[i].node2
                 }
                 });
          }

          var layout = cy.layout({
                                 name: 'circle'
                                 });
          layout.run();
          
          });
