package br.uece.aps.classes.carrinhodecompra;

import br.uece.aps.classes.livro.Livro;

public class LivroPar {
	private Livro livro;
	private int quantidade;
	
	LivroPar(Livro livro, int quantidade) {
		this.livro = livro;
		this.quantidade = quantidade;
	}	
	
	LivroPar(Livro livro) {
		this.livro = livro;
		this.quantidade = 1;
	}

	public int getQuantidade() {
		return quantidade;
	}

	public void setQuantidade(int quantidade) {
		this.quantidade = quantidade;
	}

	public Livro getLivro() {
		return livro;
	}

	public void setLivro(Livro livro) {
		this.livro = livro;
	}
	
	public String getLivroTitulo() {
		return livro.getTitulo();
	}
}
