
package br.uece.aps.classes;

public class Pessoa {
    
    protected Integer CPF;
    protected String Nome;
    protected Integer Idade;
    protected String Senha;
    protected String Email;
    protected String Endereco;

    public Integer getCPF() {
        return CPF;
    }

    public void setCPF(Integer CPF) {
        this.CPF = CPF;
    }
    
    public String getNome() {
        return Nome;
    }

    public void setNome(String Nome) {
        this.Nome = Nome;
    }

    public Integer getIdade() {
        return Idade;
    }

    public void setIdade(Integer Idade) {
        this.Idade = Idade;
    }

    public String getSenha() {
        return Senha;
    }

    public void setSenha(String Senha) {
        this.Senha = Senha;
    }

    public String getEmail() {
        return Email;
    }

    public void setEmail(String email) {
        this.Email = email;
    }

    public String getEndereco() {
        return Endereco;
    }

    public void setEndereco(String Endereco) {
        this.Endereco = Endereco;
    }
    
}
