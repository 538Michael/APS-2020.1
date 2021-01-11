package br.uece.aps.classes.livro;

public enum Categoria {
	AUTOBIOGRAFIA("autobiografia"),
	BIOGRAFIA("biografia"),
	FANTASIA("fantasia"),
	FICCAOCIENTIFICA("ficção-cientifica"),
	HORROR("horror"),
	ROMANCE("romance"),
	AUTOAJUDA("autoajuda"),
	RECEITA("receita");
	
	private final String categoria;
	Categoria(String categoria) {
		this.categoria = categoria;
	}
	
	public String getCategoria() {
		return this.categoria;
	}	
}
