package com.diegolopez.acmemonolith.repository;

import java.util.Optional;

import com.diegolopez.acmemonolith.domain.Cliente;

import org.springframework.data.jpa.repository.JpaRepository;

public interface ClienteRepository extends JpaRepository<Cliente, Long> {

	public Optional<Cliente> findByCpf(String cpf);
	
}
