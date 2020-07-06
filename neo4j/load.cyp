LOAD CSV WITH HEADERS
FROM 'file:///CYP1A2.csv' AS line
CREATE (proteinA:Protein {name: line.`Official Symbol Interactor A`})

WITH line, line.`Official Symbol Interactor B` AS proteinB_name
MERGE (proteinA:Protein {name: line.`Official Symbol Interactor A`})
WITH proteinA, proteinB_name
MATCH (proteinB:Protein {name: proteinB_name})
CREATE (proteinB)-[rel:INTERACTS_WITH]->(proteinA)