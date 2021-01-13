package br.uece.aps.classes.login;

import java.sql.*;

public final class DatabaseConnection {
    
    public void conectar(){
        try (Connection connection = DriverManager.getConnection("jdbc:sqlite:BancoDeDados.db")) {

            System.out.println("Conexão realizada !!!!");
            
            Statement statement = connection.createStatement();
            // criando uma tabela para usuários
            statement.execute("CREATE TABLE IF NOT EXISTS Contas(\n" +
            " \"cpf\" integer NOT NULL PRIMARY KEY AUTOINCREMENT,\n" +
            " \"nome\" text,\n" +
            " \"idade\" integer,\n" +
            " \"senha\" text,\n" +
            " \"email\" text,\n" +
            " \"endereco\" text,\n" +
            " \"admin\" integer DEFAULT 0\n" +
            ");");
            
            // criando uma tabela para livros
            statement.execute("CREATE TABLE IF NOT EXISTS Livros(\n" +
            " titulo text,\n" +
            " preco real,\n" +
            " avaliacao real,\n" +
            " qntavaliacoes integer DEFAULT 0,\n" +
            " editora text\n" +
            ");");
            	

        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
        
        //cadastrar(2, "Michael", 1, "123", "michael.souza@aluno.uece.br", "Rua 1 Casa 1", 1);
        //login(2, "123");
        //login(2, "1234");
    }
    
    public void cadastrar(Integer CPF, String Nome, Integer Idade, String Senha, String Email, String Endereco, Integer Admin){
        
        try (Connection connection = DriverManager.getConnection("jdbc:sqlite:BancoDeDados.db")) {
            
            PreparedStatement stmt = connection.prepareStatement("SELECT * FROM Contas WHERE cpf = " + CPF + ";");
            ResultSet resultSet = stmt.executeQuery();
            if(resultSet.next() == false){
                stmt = connection.prepareStatement("INSERT INTO Contas( cpf, nome, idade, senha, email, endereco, admin ) VALUES (?, ?, ?, ?, ?, ?, ?);");
                stmt.setInt(1, CPF);
                stmt.setString(2, Nome);
                stmt.setInt(3, Idade);
                stmt.setString(4, Senha);
                stmt.setString(5, Email);
                stmt.setString(6, Endereco);
                stmt.setInt(7, Admin);
                stmt.executeUpdate();
                
            }else{
                System.out.println("Erro no cadastro, um usuário com este cpf já foi cadastrado!");
            }

            
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
        
    }
    
    public void login(Integer CPF, String Senha){
        
        try (Connection connection = DriverManager.getConnection("jdbc:sqlite:BancoDeDados.db")) {
            
            PreparedStatement stmt = connection.prepareStatement("SELECT * FROM Contas WHERE cpf = " + CPF + ";");
            ResultSet resultSet = stmt.executeQuery();
            if(resultSet.next() == false){
                System.out.println("Erro no login, este cpf não está cadastrado no sistema!");
            }else{
                if(resultSet.getString("Senha").equals(Senha)){
                    System.out.println("Logado com sucesso!");
                }else{
                    System.out.println("Erro no login, senha errada!");
                }
                
            }

            
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
        
    }
    
    public DatabaseConnection(){
        conectar();
    }
    
}
