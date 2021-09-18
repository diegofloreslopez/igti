package com.diegolopez.acmemonolith.controller;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import com.diegolopez.acmemonolith.domain.Cliente;
import com.diegolopez.acmemonolith.domain.Fatura;
import com.diegolopez.acmemonolith.domain.Instalacao;
import com.diegolopez.acmemonolith.exception.RecursoNotFoundException;
import com.diegolopez.acmemonolith.repository.ClienteRepository;
import com.diegolopez.acmemonolith.repository.FaturaRepository;
import com.diegolopez.acmemonolith.repository.InstalacaoRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;

@RestController
@Api(value = "Acme AP Fatura Service", produces = MediaType.APPLICATION_JSON_VALUE)
public class FaturaController {

    @Autowired
    private FaturaRepository faturaRepository;

    @Autowired
    private InstalacaoRepository instalacaoRepository;

    @Autowired
    private ClienteRepository clienteRepository;

    @ApiOperation(value = "Mostra a lista de faturas")
    // Controle de versão explicito na URI
    @GetMapping("v1/faturas")
    public List<Fatura> getAllFaturas() {

        // ArrayList<Fatura> listaFaturas = new ArrayList<Fatura>();
        List<Fatura> listaFaturas;
        try {
            listaFaturas = faturaRepository.findAll();
        } catch (Exception e) {
            // TODO: handle exception
            throw new RecursoNotFoundException("Erro ao recuperar faturas");
        }

        return listaFaturas;
    }

    @ApiOperation(value = "Consulta uma fatura pelo código")
    @GetMapping("v1/faturas/{codigo}")
    public Optional<Fatura> getFatura(@PathVariable String codigo) {

        // Optional<Fatura> fatura = null;
        Optional<Fatura> fatura;

        try {
            fatura = faturaRepository.findByCodigo(codigo);
            if (fatura.get() == null)
                throw new RecursoNotFoundException("codigo de fatura inválido - " + codigo);
        } catch (Exception e) {
            // TODO: handle exception
            throw new RecursoNotFoundException("codigo de fatura inválido - " + codigo);
        }

        return fatura;
    }

    @ApiOperation(value = "Consulta as faturas pelo CPF do cliente")
    @GetMapping("v1/faturas/cpf/{cpf}")
    public List<Fatura> getFaturasPorCPF(@PathVariable String cpf) {

        // Optional<Cliente> cliente = null;
        Optional<Cliente> cliente;
        List<Instalacao> listaInstalacao;

        try {
            cliente = clienteRepository.findByCpf(cpf);
            if (cliente.get() == null)
                throw new RecursoNotFoundException("CPF - " + cpf);

            listaInstalacao = instalacaoRepository.findByCliente(cliente.get());
        } catch (Exception e) {
            // TODO: handle exception
            throw new RecursoNotFoundException("CPF inválido - " + cpf);
        }

        List<Fatura> listaFaturasCliente = new ArrayList<Fatura>();

        // listaInstalacao.stream()
        // .forEach(item -> item.getListaFatura().stream().forEach(fatura ->
        // listaFaturasCliente.add(fatura)));
        listaInstalacao.stream().forEach(item -> item.getListaFatura().stream().forEach(listaFaturasCliente::add));

        return listaFaturasCliente;
    }

    @ApiOperation(value = "Gerar uma nova fatura")
    @PostMapping("v1/faturas")
    @ResponseStatus(HttpStatus.CREATED)
    public ResponseEntity<Object> gerarFatura(@RequestBody Fatura fatura) {

        Optional<Instalacao> instalacaoRecuperada;
        // URI location = null;
        URI location;

        try {

            instalacaoRecuperada = instalacaoRepository.findByCodigo(fatura.getInstalacao().getCodigo());
            if (instalacaoRecuperada.get() == null)
                throw new RecursoNotFoundException("codigo instalacao - " + fatura.getInstalacao().getCodigo());

            fatura.setInstalacao(instalacaoRecuperada.get());

            Fatura faturaCriada = faturaRepository.save(fatura);
            location = ServletUriComponentsBuilder.fromCurrentRequest().path("/{id}")
                    .buildAndExpand(faturaCriada.getId()).toUri();

        } catch (Exception e) {
            // TODO: handle exception
            throw new RecursoNotFoundException(
                    "Erro ao gerar fatura para a instalacao - " + fatura.getInstalacao().getCodigo());
        }

        return ResponseEntity.created(location).build();
    }

}
