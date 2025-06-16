-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost
-- Tiempo de generación: 16-06-2025 a las 02:23:45
-- Versión del servidor: 10.4.28-MariaDB
-- Versión de PHP: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `gestion_equipos`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `admins`
--

CREATE TABLE `admins` (
  `id_admin` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `apellido` varchar(50) NOT NULL,
  `usuario` varchar(30) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `admins`
--

INSERT INTO `admins` (`id_admin`, `nombre`, `apellido`, `usuario`, `password`) VALUES
(1, 'Nicolás', 'Olmos', 'Nicolas', '42787465');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `docentes`
--

CREATE TABLE `docentes` (
  `id_docente` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `apellido` varchar(50) NOT NULL,
  `dni` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `docentes`
--

INSERT INTO `docentes` (`id_docente`, `nombre`, `apellido`, `dni`) VALUES
(1, 'Nicolás', 'Olmos', '42787465'),
(2, 'Prueba', 'Prueba', '77788899'),
(3, 'Hola', 'Mundo', '12345678'),
(4, 'Nico', 'Nico', '87654321');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `equipos`
--

CREATE TABLE `equipos` (
  `id_equipo` int(11) NOT NULL,
  `nombre_equipo` varchar(50) NOT NULL,
  `identificador_unico` varchar(30) NOT NULL,
  `estado` enum('disponible','prestado','mantenimiento') NOT NULL DEFAULT 'disponible'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `equipos`
--

INSERT INTO `equipos` (`id_equipo`, `nombre_equipo`, `identificador_unico`, `estado`) VALUES
(1, 'Prueba 1', 'Prueba-1', 'disponible'),
(2, 'Prueba 2', 'prueba-2', 'disponible'),
(3, 'Prueba 3', 'prueba-3', 'disponible'),
(4, 'Prueba 4', 'prueba4', 'disponible'),
(5, 'Prueba5', 'PRueba-5', 'disponible'),
(6, 'Prueba6', 'prueba_6', 'disponible'),
(7, 'prubea7', '777', 'disponible'),
(8, 'Prueba8', 'oiiqowid', 'disponible'),
(9, 'oasroij', 'skd', 'disponible'),
(10, 'sakldsamklasd', 'askmdklsa', 'disponible');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `movimientos`
--

CREATE TABLE `movimientos` (
  `id_movimiento` int(11) NOT NULL,
  `id_equipo` int(11) NOT NULL,
  `id_docente` int(11) NOT NULL,
  `fecha_hora_retiro` datetime NOT NULL,
  `fecha_hora_devolucion` datetime DEFAULT NULL,
  `observaciones` varchar(255) DEFAULT NULL,
  `curso` varchar(4) NOT NULL DEFAULT '1A'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `movimientos`
--

INSERT INTO `movimientos` (`id_movimiento`, `id_equipo`, `id_docente`, `fecha_hora_retiro`, `fecha_hora_devolucion`, `observaciones`, `curso`) VALUES
(1, 1, 1, '2025-06-11 14:22:01', '2025-06-11 14:26:49', '', '1A'),
(2, 1, 1, '2025-06-11 14:27:16', '2025-06-11 14:31:07', '', '1A'),
(3, 1, 1, '2025-06-11 14:40:13', '2025-06-11 14:58:53', '', '1A'),
(4, 1, 1, '2025-06-11 14:58:55', '2025-06-12 12:00:50', '', '1A'),
(5, 1, 1, '2025-06-12 11:58:05', '2025-06-12 11:58:09', '', '5B'),
(6, 1, 1, '2025-06-12 11:58:11', '2025-06-12 12:00:49', '', '5B'),
(7, 1, 1, '2025-06-12 12:00:52', '2025-06-12 12:00:54', '', '5B'),
(8, 1, 1, '2025-06-12 12:00:57', '2025-06-12 12:01:06', '', '5B'),
(9, 1, 1, '2025-06-12 12:01:10', '2025-06-12 12:04:19', '', '7A'),
(10, 1, 1, '2025-06-12 12:04:33', '2025-06-13 10:00:00', '', '7A'),
(11, 1, 1, '2025-06-13 09:59:55', '2025-06-13 10:00:00', '', '7A'),
(12, 1, 1, '2025-06-13 10:00:03', '2025-06-13 10:00:06', '', '7A'),
(13, 1, 1, '2025-06-13 10:11:48', '2025-06-13 10:11:55', '', '3A'),
(14, 1, 1, '2025-06-15 19:51:19', '2025-06-15 19:51:23', '', '2A'),
(15, 1, 1, '2025-06-15 19:54:25', '2025-06-15 19:59:12', '', '4A'),
(16, 8, 1, '2025-06-15 20:01:41', '2025-06-15 20:01:49', '', '3B'),
(17, 7, 1, '2025-06-15 20:01:42', '2025-06-15 20:01:48', '', '3B'),
(18, 3, 1, '2025-06-15 20:04:58', '2025-06-15 21:06:12', '', '2B'),
(19, 5, 1, '2025-06-15 20:04:59', '2025-06-15 21:06:12', '', '2B'),
(20, 6, 1, '2025-06-15 20:05:00', '2025-06-15 21:06:12', '', '2B'),
(21, 1, 1, '2025-06-15 20:11:09', '2025-06-15 21:06:11', '', '3A'),
(22, 2, 1, '2025-06-15 20:11:09', '2025-06-15 21:06:11', '', '3A'),
(23, 4, 1, '2025-06-15 20:11:10', '2025-06-15 21:06:10', '', '3A'),
(24, 7, 1, '2025-06-15 20:11:10', '2025-06-15 21:06:10', '', '3A'),
(25, 8, 1, '2025-06-15 20:11:11', '2025-06-15 21:06:09', '', '3A'),
(26, 9, 1, '2025-06-15 20:11:11', '2025-06-15 21:06:09', '', '3A'),
(27, 10, 1, '2025-06-15 20:11:12', '2025-06-15 21:06:00', '', '3A'),
(28, 1, 1, '2025-06-15 21:06:28', '2025-06-15 21:11:07', '', '2A'),
(29, 1, 1, '2025-06-15 21:11:42', NULL, '', '1A'),
(30, 1, 2, '2025-06-15 21:12:37', '2025-06-15 21:12:48', '', '6B');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id_admin`),
  ADD UNIQUE KEY `usuario` (`usuario`);

--
-- Indices de la tabla `docentes`
--
ALTER TABLE `docentes`
  ADD PRIMARY KEY (`id_docente`),
  ADD UNIQUE KEY `dni` (`dni`);

--
-- Indices de la tabla `equipos`
--
ALTER TABLE `equipos`
  ADD PRIMARY KEY (`id_equipo`),
  ADD UNIQUE KEY `identificador_unico` (`identificador_unico`);

--
-- Indices de la tabla `movimientos`
--
ALTER TABLE `movimientos`
  ADD PRIMARY KEY (`id_movimiento`),
  ADD KEY `id_equipo` (`id_equipo`),
  ADD KEY `id_docente` (`id_docente`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `admins`
--
ALTER TABLE `admins`
  MODIFY `id_admin` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `docentes`
--
ALTER TABLE `docentes`
  MODIFY `id_docente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `equipos`
--
ALTER TABLE `equipos`
  MODIFY `id_equipo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `movimientos`
--
ALTER TABLE `movimientos`
  MODIFY `id_movimiento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `movimientos`
--
ALTER TABLE `movimientos`
  ADD CONSTRAINT `movimientos_ibfk_1` FOREIGN KEY (`id_equipo`) REFERENCES `equipos` (`id_equipo`),
  ADD CONSTRAINT `movimientos_ibfk_2` FOREIGN KEY (`id_docente`) REFERENCES `docentes` (`id_docente`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
