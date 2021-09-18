package com.diegolopez.acmemonolith.repository;

import java.util.List;
import java.util.Optional;

import com.diegolopez.acmemonolith.domain.Fatura;
import com.diegolopez.acmemonolith.domain.Instalacao;

import org.springframework.data.jpa.repository.JpaRepository;

public interface FaturaRepository extends JpaRepository<Fatura, Long> {

	public Optional<Fatura> findByCodigo(String codigo);
	public List<Fatura> findByInstalacao(Instalacao instalacao);
	
}
