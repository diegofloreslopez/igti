package com.diegolopez.acmemonolith.repository;

import java.util.List;
import java.util.Optional;

import com.diegolopez.acmemonolith.domain.Cliente;
import com.diegolopez.acmemonolith.domain.Instalacao;

import org.springframework.data.jpa.repository.JpaRepository;

public interface InstalacaoRepository extends JpaRepository<Instalacao, Long> {

	public Optional<Instalacao> findByCodigo(String codigo);
	public List<Instalacao> findByCliente(Cliente cliente);
	
}
