package br.uece.aps.classes.carrinhodecompra;

import java.util.List;

public class CarrinhoDeCompras {
	private float preco;
	private List<LivroPar> carrinho;
	
	public CarrinhoDeCompras() {
		this.preco = 0;
	}

	public void updateCarrinho(List<LivroPar> livros) {
		this.carrinho = livros;
	}
	
	public void updateCarrinho(LivroPar livro) {
		this.carrinho.add(livro);
	}
	
	public void removeLivroPar(LivroPar livro) {
		int index = this.carrinho.indexOf(livro);
		if(index != -1) {
			carrinho.remove(index);
		}
	}
	
	public void removeLivroPar(String titulo) {
		for(LivroPar livro : this.carrinho) {
			if(livro.getLivroTitulo() == titulo) {
				livro.setQuantidade( livro.getQuantidade()-1 );
				if(livro.getQuantidade() == 0) {
					this.removeLivroPar(livro);
				}
				break;
			}
		}
	}
	
	public float getPreco() {
		return this.preco;
	}
	
	public void setPreco() {
		this.preco = 0;
		for(LivroPar livro : this.carrinho) {
			this.preco += livro.getLivro().getPreco() * livro.getQuantidade();
		}
	}
	
	public void finalizaCompra() {
		//TODO;
	}
	
	
}
