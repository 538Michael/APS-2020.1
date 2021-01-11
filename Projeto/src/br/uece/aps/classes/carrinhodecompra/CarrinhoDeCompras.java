package br.uece.aps.classes.carrinhodecompra;

import java.util.List;

import br.uece.aps.classes.livro.Livro;

public class CarrinhoDeCompras {
	private float preco;
	private List<Livro> livros; //Não armazena quantos de cada livro tem ainda.
	
	public CarrinhoDeCompras() {
		this.preco = 0;
	}

	public void updateLivros(List<Livro> livros) {
		this.livros = livros;
	}
	
	public void updateLivros(Livro livro) {
		this.livros.add(livro);
	}
	
	public void removeLivro(Livro livro) {
		int index = this.livros.indexOf(livro);
		if(index != -1) {
			livros.remove(index);
		}
	}
	
	public void removeLivro(String titulo) {
		for(Livro livro : this.livros) {
			if(livro.getTitulo() == titulo) {
				this.livros.remove(livro);
				break;
			}
		}
	}
	
	public float getPreco() {
		return this.preco;
	}
	
	public void setPreco() {
		this.preco = 0;
		for(Livro livro : this.livros) {
			this.preco += livro.getPreco();
		}
	}
	
	public void finalizaCompra() {
		//TODO;
	}
	
	
}
