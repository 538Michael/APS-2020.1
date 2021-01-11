package br.uece.aps.classes.livro;

public enum Autor {
	CLARICE("Clarice Lispector"),
	ASSIS("Machado de Assis"),
	KAFKA("Franz Kafka"),
	DRUMMOND("Carlos Drummond"),
	SHAKESPEARE("William Shakespeare"),
	ALENCAR("José de Alencar"),
	ANDRZEJ("Andrzej Sapkowski");
	
	private final String autor;
	Autor(String autor) {
		this.autor = autor;
	}
	
	public String getAutor() {
		return this.autor;
	}
}
