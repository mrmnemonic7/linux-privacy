/*
 * Leet Text Wrangler
 *
 * Converts any given phrase to lowercase then to 1337/leet speak, then also to ASCII, SHA512 and Base64.
 * By: MrMnemonic7 (mrmnemonic7@protonmail.ch)
 * Released under the MIT license.
 * 
 * Compile with: gcc -DDEBUG -DUSE_SSL -o leet leet.c -lcrypto
 */
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

#ifdef USE_SSL
#include <openssl/sha.h>
#endif

#define BUFFERSIZE 256

const char b64chars[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

size_t b64_encoded_size(size_t inlen)
{
	size_t ret;

	ret = inlen;
	if (inlen % 3 != 0)
		ret += 3 - (inlen % 3);
	ret /= 3;
	ret *= 4;

	return ret;
}

char *b64_encode(const unsigned char *in, size_t len)
{
	char   *out;
	size_t  elen;
	size_t  i;
	size_t  j;
	size_t  v;

	if (in == NULL || len == 0)
		return NULL;

	elen = b64_encoded_size(len);
	out  = malloc(elen+1);
	out[elen] = '\0';

	for (i=0, j=0; i<len; i+=3, j+=4) {
		v = in[i];
		v = i+1 < len ? v << 8 | in[i+1] : v << 8;
		v = i+2 < len ? v << 8 | in[i+2] : v << 8;

		out[j]   = b64chars[(v >> 18) & 0x3F];
		out[j+1] = b64chars[(v >> 12) & 0x3F];
		if (i+1 < len) {
			out[j+2] = b64chars[(v >> 6) & 0x3F];
		} else {
			out[j+2] = '=';
		}
		if (i+2 < len) {
			out[j+3] = b64chars[v & 0x3F];
		} else {
			out[j+3] = '=';
		}
	}

	return out;
}

/* modifies 'str_input' */
int ascii_convert(char str_input[])
{
    int l=0;
    int wl=0;

    wl=strlen(str_input);
    /* Do letter replacement */
    for(l=0; l<wl; l++)
    {
        printf("%d", str_input[l]);
        /*
        if(l == (wl - 1) ) {
            printf("%d", str_input[l]);
        } else {
            printf("%d,", str_input[l]);
        }
        */
    }
    //putchar('\n');
    return 0;
}

int leet_convert(char str_input[], char output[])
{
    int i,l=0;
    
    /* Do letter replacement */
    for(l=0;l<strlen(str_input);l++)
    {
        switch(str_input[l])
        {
            case 'o':
                output[l]='0';
                break;
            case 'e':
                output[l]='3';
                break;
            case 'i':
                output[l]='1';
                break;
            case 'a':
                output[l]='4';
                break;
            case 's':
                output[l]='5';
                break;
            case 't':
                output[l]='7';
                break;
            default:
                output[l]=str_input[l];
                break;
        }
    }
    return 0;
}

int main(int argc, char *arv[])
{
    int i;
    char my_string[]="";
    char output[BUFFERSIZE]={0};
    char input_buffer[BUFFERSIZE]={0};
    char buffer_leet[BUFFERSIZE]={0};
    char buffer_hash[BUFFERSIZE]={0};
    char buffer_ascii[BUFFERSIZE]={0};
    char *buffer_base64;

    /* If no predefined string exists, get it from the user */
    if(strlen(my_string)<1)
    {
        printf("Enter string: ");
        /* get user input */
        fgets(input_buffer, BUFFERSIZE , stdin);
        if(strlen(input_buffer)<1) return 1;
        input_buffer[strcspn(input_buffer, "\r\n")] = 0;
        //input_buffer[strlen(input_buffer)-1] = '\0';

        if(strlen(input_buffer)<1)
        {
            fprintf(stderr, "Error receiving input\n");
            return 1;
        }
    } else {
        strcpy(input_buffer, my_string);
    }
   
    #ifdef DEBUG
    printf("DEBUG: ");
    for(i=0; i<strlen(input_buffer); i++)
    {
        printf("[%c]", input_buffer[i]);
    }
    putchar('\n');
    printf("Original: [%s]\n", input_buffer);
    #endif

    /* convert to lowercase first */
    for(i = 0; input_buffer[i]; i++)
    {
        input_buffer[i] = tolower(input_buffer[i]);
    }
    #ifdef DEBUG
    printf("Lowercase: [%s]\n", input_buffer);
    #endif

    leet_convert(input_buffer, buffer_leet);
    #ifdef DEBUG
    printf("1337: [%s]\n", buffer_leet);
    #endif

    #ifdef DEBUG
    strcpy(buffer_ascii, buffer_leet);
    printf("ASCII: [");
    ascii_convert(buffer_ascii);
    putchar(']');
    putchar('\n');
    #else
    fprintf(stdout, "%s", buffer_ascii);
    #endif

    #ifdef DEBUG
    #ifdef USE_SSL
    unsigned char hash[SHA512_DIGEST_LENGTH];
    SHA512((unsigned char*)buffer_leet, strlen(buffer_leet), (unsigned char*)&hash);
    printf("SHA512: [");
    //printf("%s", hash);
    for(int i = 0; i < SHA512_DIGEST_LENGTH; ++i) {
        printf("%02x", hash[i]);
    }
    putchar(']');
    putchar('\n');
    #endif
    #endif
    
    buffer_base64 = b64_encode((const unsigned char *)buffer_leet, strlen(buffer_leet));
	printf("Base64: [%s]\n", buffer_base64);

    return 0;
}
