package br.uece.aps.classes.livro;

import java.util.List;

public class Livro {
    private String titulo;
    private float preco;
    private float avaliacao;
    private float qntAvaliacoes;
    private Editora editora;
    private List<Autor> autores;
    private List<Categoria> categorias;
  
    
    public Livro(String titulo, float preco, Editora editora) {
    	this.titulo = titulo;
    	this.preco = preco;
    	this.editora = editora;
    	this.avaliacao = 0;
    	this.qntAvaliacoes = 0;
    }

	public String getTitulo() {
		return titulo;
	}

	public void setTitulo(String titulo) {
		this.titulo = titulo;
	}

	public float getPreco() {
		return preco;
	}

	public void setPreco(float preco) {
		this.preco = preco;
	}
	
	public void resetAvaliacao() {
		this.avaliacao = 0;
		this.qntAvaliacoes = 0;
	}
	
	public void updateAvaliacao(float avaliacao) {
		this.avaliacao *= this.qntAvaliacoes;
		this.avaliacao = (this.avaliacao + this.avaliacao) / ++this.qntAvaliacoes;
	}
	
	public String getEditora() {
		return editora.getEditora();
	}
	
	public void updateCategoria(Categoria categoria) {
		this.categorias.add(categoria);
	}
	
	public void updateCategoria(List<Categoria> categorias) {
		this.categorias = categorias;
	}
	
	public void removeCategoria(Categoria categoria) {
		int index = this.categorias.indexOf(categoria);
		if(index != -1) {
			categorias.remove(index);
		}
	}
	
	public void updateAutores(Autor autor) {
		this.autores.add(autor);
	}
	
	public void updateAutores(List<Autor> autores) {
		this.autores = autores;
	}
	
	public void removeAutor(Autor autor) {
		int index = this.autores.indexOf(autor);
		if(index != -1) {
			categorias.remove(index);
		}
	}
	
}
