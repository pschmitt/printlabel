#!/usr/bin/env python3

"""Minimal PackBits codec used by the printer transport."""


def encode(data: bytes) -> bytes:
    """Encode bytes with the PackBits run-length scheme."""

    if not data:
        return b""

    encoded = bytearray()
    length = len(data)
    i = 0

    while i < length:
        run_length = 1
        while (
            i + run_length < length
            and data[i + run_length] == data[i]
            and run_length < 128
        ):
            run_length += 1

        if run_length >= 3:
            encoded.append((257 - run_length) & 0xFF)
            encoded.append(data[i])
            i += run_length
            continue

        literal_start = i
        literal_length = 0

        while i < length and literal_length < 128:
            run_length = 1
            while (
                i + run_length < length
                and data[i + run_length] == data[i]
                and run_length < 128
            ):
                run_length += 1

            if run_length >= 3:
                break

            i += 1
            literal_length += 1

        encoded.append(literal_length - 1)
        encoded.extend(data[literal_start : literal_start + literal_length])

    return bytes(encoded)


def decode(data: bytes) -> bytes:
    """Decode PackBits-encoded bytes."""

    decoded = bytearray()
    i = 0
    length = len(data)

    while i < length:
        header = data[i]
        i += 1

        if header <= 127:
            literal_length = header + 1
            decoded.extend(data[i : i + literal_length])
            i += literal_length
            continue

        if header == 128:
            continue

        repeat_length = 257 - header
        if i >= length:
            raise ValueError("Malformed PackBits stream")

        decoded.extend([data[i]] * repeat_length)
        i += 1

    return bytes(decoded)
