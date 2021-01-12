package br.uece.aps.classes.livro;

import java.util.ArrayList;
import java.util.List;

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
	
	public static String[] getListaCategoria() {
		List<String> list = new ArrayList<>();
		for(Categoria it : Categoria.values()) {
			list.add(it.getCategoria());
		}
		return list.toArray(new String[0]);
	}
}
