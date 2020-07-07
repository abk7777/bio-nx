MATCH (n) DETACH DELETE n;

LOAD CSV WITH HEADERS
FROM 'file:///graph_data.csv' AS line

// Interaction nodes
CREATE (i:Interaction { 
	biogrid_id: line.`BioGRID Interaction ID`,
	author: line.Author,
    pubmed_id: line.`Pubmed ID`,
    experimental_system: line.`Experimental System`,
    experimental_system_type: line.`Experimental System Type`,
    throughput: line.`Throughput`,
    gene_a: line.`Official Symbol Interactor A`,
    entrez_id_a: line.`Entrez Gene Interactor A`,
    synonyms_a: line.`Synonyms Interactor A`,
    organism_a: line.`Organism Interactor A`,
    gene_b: line.`Official Symbol Interactor B`,
    entrez_id_b: line.`Entrez Gene Interactor A`,
    synonyms_b: line.`Synonyms Interactor B`,
    organism_b: line.`Organism Interactor B`    
    });
    
MATCH (i:Interaction)
WITH DISTINCT i.gene_a as name
CREATE (g:Gene { name: name });

MATCH (i:Interaction)
WITH DISTINCT i.gene_b as name
MERGE (g:Gene { name: name });