MATCH (n) DETACH DELETE n;

LOAD CSV WITH HEADERS
FROM 'file:///graph_data.csv' AS line

// Interaction nodes
CREATE (:Interaction { 
	biogrid_id: line.`BioGRID Interaction ID`,
	author: line.Author,
    pubmed_id: line.`Pubmed ID`,
    publication_year: line.`Publication Year`,
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
    
// Create Gene nodes
MATCH (i:Interaction)
WITH split(apoc.text.join(collect(i.gene_a + ", " + i.gene_b), 
	", "), ", ") as genes
UNWIND genes as gene
WITH DISTINCT gene
CREATE (:Gene { name: gene });

// Create (Gene)-[:INTERACTOR_IN]->(Interaction)
MATCH (i:Interaction)
WITH i, split(apoc.text.join(collect(i.gene_a + ", " + i.gene_b), 
	", "), ", ") as genes
UNWIND genes as gene
MATCH (g:Gene { name: gene })
MERGE (g)-[:INTERACTOR_IN]->(i);

// Set Gene node properties
MATCH (i:Interaction)
WITH i, i.gene_a as gene, i.entrez_id_a as entrez_id, i.synonyms_a as synonyms, i.organism_a as organism
MATCH (g:Gene { name: gene })
SET g.entrez_id = entrez_id, g.synonyms = synonyms, g.organism = organism;

MATCH (i:Interaction)
WITH i, i.gene_b as gene, i.entrez_id_b as entrez_id, i.synonyms_b as synonyms, i.organism_b as organism
MATCH (g:Gene { name: gene })
SET g.entrez_id = entrez_id, g.synonyms = synonyms, g.organism = organism;

MATCH (g:Gene) WITH g
SET g.ncbi_url = "", g.wikipedia_url = "", g.locus_type = "", 
	g.full_sequence = "", g.chromosome_location = "", 
    g.base_pairs = "";

// Create (Gene1)-[:INTERACTS_WITH]-(Gene2)
MATCH (g1:Gene)-[:INTERACTOR_IN]->(i:Interaction),
	(g2:Gene)-[:INTERACTOR_IN]->(i)
MERGE (g1)-[:INTERACTS_WITH]-(g2);

// Create Article nodes
MATCH (i:Interaction)
WITH DISTINCT [i.pubmed_id, i.author, i.publication_year] as article_node
CREATE (:Article { 
	pubmed_id: article_node[0],
    author: article_node[1],
    publication_year: article_node[2]
    });

// Create (Interaction)-[:MENTIONED_IN]->(Article)
MATCH (i:Interaction)
WITH i, i.pubmed_id as pubmed_id
MATCH (a:Article) WHERE a.pubmed_id = pubmed_id
MERGE (i)-[:MENTIONED_IN]->(a);

// Create (Gene)-[:MENTIONED_IN]->(Article)
MATCH (i:Interaction)-[:MENTIONED_IN]->(a:Article)
WITH i, a, [i.gene_a, i.gene_b] as genes
MATCH (g:Gene) WHERE g.name IN genes
MERGE (g)-[:MENTIONED_IN]->(a);