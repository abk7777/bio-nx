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
    entrez_id_b: line.`Entrez Gene Interactor B`,
    synonyms_b: line.`Synonyms Interactor B`,
    organism_b: line.`Organism Interactor B`    
    });
    
MATCH (i:Interaction)
WITH split(apoc.text.join(collect(i.gene_a + ", " + i.gene_b), 
	", "), ", ") as genes
UNWIND genes as gene
WITH DISTINCT gene
CREATE (g:Gene { name: gene  })



// , i.entrez_id_a as entrez_id, 
// 	i.synonyms_a as synonyms, i.organism_a as organism

//     ,
//     entrez_id_a: entrez_id,
//     synonyms_a: synonyms,
//     organism_a: organism