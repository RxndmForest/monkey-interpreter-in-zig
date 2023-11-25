const std = @import("std");
const token = @import("tokens.zig");

const Token = token.Token;
const TokenMap = token.TokenType;

const Lexer = struct {
    const Self = @This();
    allocator: *std.mem.Allocator,
    input: []const u8,
    position: i16,
    read_position: i16,
    ch: []const u8,

    fn nextToken(self:Self) !void {
        var tok = token.Token;

        self.skipWhiteSpace();

        switch (Self.ch) {
            '=' => {
                if (self.peekChar() == '=') {
                    var ch = self.ch;
                    self.readChar();
                    var literal = ch + self.ch;
                    var tok = token.Token{.Type = TokenMap.EQ, .Literal = literal};
                } else {
                    var tok = newToken(TokenMap.ASSIGN, Self.ch);
                }
            },
            '+' => {tok = newToken(TokenMap.PLUS, Self.ch);},
            '-' => {tok = newToken(TokenMap.MINUS, Self.ch);},
            '/' => {tok = newToken(TokenMap.SLASH, Self.ch);},
            '!' => {
                if (self.peekChar() == '=') {
                    var ch = self.ch;
                    self.readChar();
                    // are we adding two strings here?
                    var literal = ch + self.ch;
                    var tok = token.Token{.Type = TokenMap.NOT_EQ, .Literal = literal};
                } else {
                    var tok = newToken(TokenMap.BANG, self.ch);
                }
            },
            '*' => {tok = newToken(TokenMap.ASTERISK, Self.ch);},
            '<' => {tok = newToken(TokenMap.LT, Self.ch);},
            '>' => {tok = newToken(TokenMap.GT, Self.ch);},
            ';' => {tok = newToken(TokenMap.SEMICOLON, Self.ch);},
            ':' => {tok = newToken(TokenMap.COLON, Self.ch);},
            ',' => {tok = newToken(TokenMap.COMMA, Self.ch);},
            '{' => {tok = newToken(TokenMap.LBRACE, Self.ch);},
            '}' => {tok = newToken(TokenMap.RBRACE, Self.ch);},
            '(' => {tok = newToken(TokenMap.LPAREN, Self.ch);},
            ')' => {tok = newToken(TokenMap.RPAREN, Self.ch);},
            '[' => {tok = newToken(TokenMap.LBRACKET, Self.ch);},
            ']' => {tok = newToken(TokenMap.RBRACKET, Self.ch);},
            0 => {token.Token{.Type = TokenMap.EOF, .Literal = ""};},
            else => {
                if (self.isLetter(self.ch)) {
                    token.Token{.Type = token.LookupIdent(tok.Literal), .Literal = self.readIdentifier()};
                    return tok;
                } else if (self.isDigit(self.ch)) {
                    token.Token{.Type = Token.INT, .Literal = self.readNumber()};
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
        return token.Token{.Type = tokenType, .Literal = ch};
    }
};
