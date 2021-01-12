package br.uece.aps.classes;

import br.uece.aps.classes.livro.Autor;
import br.uece.aps.classes.livro.Categoria;
import br.uece.aps.classes.livro.Editora;
import br.uece.aps.classes.livro.Livro;

public class Admin extends Cliente {
    
    public void adicionarLivro(){
    	System.out.println("Insira os dados do livro:");
    	// Na interface é para o admin editar as informações do livro
    	Livro livro = new Livro("",0,null);
    	livro.updateAutores(null);
    	livro.updateCategoria(null);
    	livro.addToDatabase();
    }
    
    public void gerenciarPedidos(){
        
    }
    
    public void relatorioVendasDia(){
        
    }
    
}
