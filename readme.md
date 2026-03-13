# HolyP

HolyP is an adaption of HolyC for polytoria.

## Planned
When Polytoria uses Luau, this project will use Luau's buffers but, a via wrapper so that way the project can maintain full compatability with Lua 5.2.

### Differences Between HolyC and HolyP
Most of everything is the same but, there are different types
and it removes the "print if its an expression".
It of course also doesn't have inline assembly as this language isn't compiled, it is interpereted.
HolyP also removes some of the preprocessor. The only preprocessor instructions it has is:
- Include
- Assert

### Syntax
```HC
Int Main() {
	// Declaring a variable
	Int x = 10;
	Float y = 10.0;
	String z = "This is a string";
	// In HolyP, there is a builtin string class as it is simpler than using a Int*.
	// HolyP stores the length of string ( Because it is implemented in lua ) So there is no point in using Int* for strings.

	for (Int j = 0; j < 10; ++j) {
		Printf("%d", j);
	}
	
	return 1;
}

Main;
```

## Special Thanks
- Terry A. Davis
- https://github.com/SpaciousCoder78/holyc-docs/tree/main
- https://templeos.net/holyc/
- https://tinkeros.github.io/WbTempleOS/
