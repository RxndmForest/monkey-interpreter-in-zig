const std = @import("std");
const token = @import("tokens.zig");
const print = std.debug.print;

const Token = token.Token;
const TokenMap = token.TokenType;

pub fn New(input: []const u8) Lexer {
    return .{ .input = input };
}

const Lexer = struct {
    const Self = @This();
    input: []const u8,
    position: i16,
    read_position: i16,
    ch: []const u8,

    fn nextToken(self: Self) !void {
        var tok: token.Token = undefined;

        self.skipWhiteSpace();

        switch (Self.ch) {
            '=' => {
                if (self.peekChar() == '=') {
                    var ch = self.ch;
                    self.readChar();
                    var literal = ch + self.ch;
                    tok = token.Token{ .Type = TokenMap.EQ, .Literal = literal };
                } else {
                    tok = newToken(TokenMap.ASSIGN, Self.ch);
                }
            },
            '+' => {
                tok = newToken(TokenMap.PLUS, Self.ch);
            },
            '-' => {
                tok = newToken(TokenMap.MINUS, Self.ch);
            },
            '/' => {
                tok = newToken(TokenMap.SLASH, Self.ch);
            },
            '!' => {
                if (self.peekChar() == '=') {
                    var ch = self.ch;
                    self.readChar();
                    // are we adding two strings here?
                    var literal = ch + self.ch;
                    tok = token.Token{ .Type = TokenMap.NOT_EQ, .Literal = literal };
                } else {
                    tok = newToken(TokenMap.BANG, self.ch);
                }
            },
            '*' => {
                tok = newToken(TokenMap.ASTERISK, Self.ch);
            },
            '<' => {
                tok = newToken(TokenMap.LT, Self.ch);
            },
            '>' => {
                tok = newToken(TokenMap.GT, Self.ch);
            },
            ';' => {
                tok = newToken(TokenMap.SEMICOLON, Self.ch);
            },
            ':' => {
                tok = newToken(TokenMap.COLON, Self.ch);
            },
            ',' => {
                tok = newToken(TokenMap.COMMA, Self.ch);
            },
            '{' => {
                tok = newToken(TokenMap.LBRACE, Self.ch);
            },
            '}' => {
                tok = newToken(TokenMap.RBRACE, Self.ch);
            },
            '(' => {
                tok = newToken(TokenMap.LPAREN, Self.ch);
            },
            ')' => {
                tok = newToken(TokenMap.RPAREN, Self.ch);
            },
            '[' => {
                tok = newToken(TokenMap.LBRACKET, Self.ch);
            },
            ']' => {
                tok = newToken(TokenMap.RBRACKET, Self.ch);
            },
            0 => {
                token.Token{ .Type = TokenMap.EOF, .Literal = "" };
            },
            else => {
                if (self.isLetter(self.ch)) {
                    token.Token{ .Type = token.LookupIdent(tok.Literal), .Literal = self.readIdentifier() };
                    return tok;
                } else if (self.isDigit(self.ch)) {
                    token.Token{ .Type = Token.INT, .Literal = self.readNumber() };
                    return tok;
                } else {
                    tok = newToken(TokenMap.ILLEGAL, self.ch);
                }
            },
        }
        self.readChar();
        return tok;
    }

    fn isWhiteSpace(self: Self) bool {
        return self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r';
    }

    fn isLetter(self: Self) bool {
        return ('a' <= self.ch and self.ch <= 'z') or ('A' <= self.ch and self.ch <= 'Z') or (self.ch == '_');
    }

    fn isDigit(self: Self) bool {
        return '0' <= self.ch and self.ch <= 9;
    }

    fn readChar(self: Self) !void {
        if (self.read_position >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.read_position];
        }
        self.position = self.read_position;
        self.read_position += 1;
    }

    fn peekChar(self: Self) []const u8 {
        if (self.read_position >= self.input.len) {
            return 0;
        } else {
            return self.input[self.read_position];
        }
    }

    fn readIdentifier(self: Self) []const u8 {
        var position = self.position;
        // unclear if this will cause the correct behavior? We essentially want to
        // continue until we return false?
        if (self.isLetter(self.ch)) {
            self.readChar();
        }
        return self.input[position..self.position];
    }

    fn readNumber(self: Self) []const u8 {
        var position = self.position;
        // again, it is unclear just like readIdentifier if this will give us desired behavior
        if (self.isDigit(self.ch)) {
            self.readChar();
        }
        return self.input[position..self.position];
    }

    fn readString(self: Self) []const u8 {
        var position = self.position + 1;
        // unclear behavior?
        // I think this wants to say that while we can read a next character
        // check that we arent at the end of a line via an string ender '"' or
        // ch == 0 which is set when we read a char number or digit?
        while (true) {
            self.readChar();
            if (self.ch == '"' or self.ch == 0) {
                break;
            }
        }
        return self.input[position..self.position];
    }

    fn skipWhiteSpace(self: Self) !void {
        while (self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r') {
            self.readChar();
        }
    }

    fn newToken(tokenType: token.TokeyType, ch: []const u8) Token {
        return token.Token{ .Type = tokenType, .Literal = ch };
    }
};

test "lexer" {
    print("/n", .{});
    defer {
        print("/n", .{});
    }

    const input: []const u8 =
        \\let five = 5;
        \\let ten = 10;
        \\
        \\let add = fn(x, y) {
        \\  x + y;
        \\};
        \\
        \\let result = add(five, ten);
        \\!-/*5;
        \\5 < 10 > 5;
        \\
        \\if (5< 10) {
        \\  return true;
        \\} else {
        \\  return false;
        \\}
        \\
        \\10 == 10;
        \\10 != 9;
    ;

    const expected = [_]token.Token{
        .{ .type = token.TokenType.LET, .literal = "let" },
        .{ .type = token.TokenType.IDENT, .literal = "five" },
        .{ .type = token.TokenType.ASSIGN, .literal = "=" },
        .{ .type = token.TokenType.INT, .literal = "5" },
        .{ .type = token.TokenType.SEMICOLON, .literal = ";" },
        .{ .type = token.TokenType.LET, .literal = "let" },
        .{ .type = token.TokenType.IDENT, .literal = "ten" },
        .{ .type = token.TokenType.ASSIGN, .literal = "=" },
        .{ .type = token.TokenType.INT, .literal = "10" },
        .{ .type = token.TokenType.SEMICOLON, .literal = ";" },
        .{ .type = token.TokenType.LET, .literal = "let" },
        .{ .type = token.TokenType.IDENT, .literal = "add" },
        .{ .type = token.TokenType.ASSIGN, .literal = "=" },
        .{ .type = token.TokenType.FUNCTION, .literal = "fn" },
        .{ .type = token.TokenType.LPAREN, .literal = "(" },
        .{ .type = token.TokenType.IDENT, .literal = "x" },
        .{ .type = token.TokenType.COMMA, .literal = "," },
        .{ .type = token.TokenType.IDENT, .literal = "y" },
        .{ .type = token.TokenType.RPAREN, .literal = ")" },
        .{ .type = token.TokenType.LBRACE, .literal = "{" },
        .{ .type = token.TokenType.IDENT, .literal = "x" },
        .{ .type = token.TokenType.PLUS, .literal = "+" },
        .{ .type = token.TokenType.IDENT, .literal = "y" },
        .{ .type = token.TokenType.SEMICOLON, .literal = ";" },
        .{ .type = token.TokenType.RBRACE, .literal = "}" },
        .{ .type = token.TokenType.SEMICOLON, .literal = ";" },
        .{ .type = token.TokenType.LET, .literal = "let" },
        .{ .type = token.TokenType.IDENT, .literal = "result" },
        .{ .type = token.TokenType.ASSIGN, .literal = "=" },
        .{ .type = token.TokenType.IDENT, .literal = "add" },
        .{ .type = token.TokenType.RPAREN, .literal = "(" },
        .{ .type = token.TokenType.IDENT, .literal = "five" },
        .{ .type = token.TokenType.COMMA, .literal = "," },
        .{ .type = token.TokenType.IDENT, .literal = "ten" },
        .{ .type = token.TokenType.RPAREN, .literal = ")" },
        .{ .type = token.TokenType.SEMICOLON, .literal = ";" },
        .{ .type = token.TokenType.BANG, .literal = "!" },
        .{ .type = token.TokenType.MINUS, .literal = "-" },
        .{ .type = token.TokenType.SLASH, .literal = "/" },
        .{ .type = token.TokenType.ASTERISK, .literal = "*" },
        .{ .type = token.TokenType.INT, .literal = "5" },
        .{ .type = token.TokenType.SEMICOLON, .literal = ";" },
        .{ .type = token.TokenType.LT, .literal = "<" },
        .{ .type = token.TokenType.INT, .literal = "10" },
        .{ .type = token.TokenType.GT, .literal = ">" },
        .{ .type = token.TokenType.INT, .literal = "5" },
        .{ .type = token.TokenType.SEMICOLON, .literal = ";" },
        .{ .type = token.TokenType.IF, .literal = "if" },
        .{ .type = token.TokenType.LPAREN, .literal = "(" },
        .{ .type = token.TokenType.INT, .literal = "5" },
        .{ .type = token.TokenType.LT, .literal = "<" },
        .{ .type = token.TokenType.INT, .literal = "10" },
        .{ .type = token.TokenType.RPAREN, .literal = ")" },
        .{ .type = token.TokenType.LBRACE, .literal = "{" },
        .{ .type = token.TokenType.RETURN, .literal = "return" },
        .{ .type = token.TokenType.TRUE, .literal = "true" },
        .{ .type = token.TokenType.SEMICOLON, .literal = ";" },
        .{ .type = token.TokenType.RBRACE, .literal = "}" },
        .{ .type = token.TokenType.ELSE, .literal = "else" },
        .{ .type = token.TokenType.LBRACE, .literal = "{" },
        .{ .type = token.TokenType.RETURN, .literal = "return" },
        .{ .type = token.TokenType.FALSE, .literal = "false" },
        .{ .type = token.TokenType.SEMICOLON, .literal = ";" },
        .{ .type = token.TokenType.RBRACE, .literal = "}" },
        .{ .type = token.TokenType.INT, .literal = "10" },
        .{ .type = token.TokenType.EQ, .literal = "==" },
        .{ .type = token.TokenType.INT, .literal = "10" },
        .{ .type = token.TokenType.SEMICOLON, .literal = ";" },
        .{ .type = token.TokenType.INT, .literal = "10" },
        .{ .type = token.TokenType.NOT_EQ, .literal = "!=" },
        .{ .type = token.TokenType.INT, .literal = "9" },
        .{ .type = token.TokenType.SEMICOLON, .literal = ";" },
    };

    var lexer = New(input);
    var i: u8 = 0;

    while (lexer.nextToken()) |tokenItr| : (i += 1) {
        print("{d}\t{}\n", .{ tokenItr.literal, tokenItr.type });
        // access the i-th element of expected
        const expected_tok = expected[i];
        // see if the expected type equals the actual type
        try std.testing.expectEqual(expected_tok.type, tokenItr.type);
        // access the expected literal
        try std.testing.expectEqual(expected_tok.literal[0], tokenItr.literal[0]);
    }
}
