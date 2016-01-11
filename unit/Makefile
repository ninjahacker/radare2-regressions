all: test_list test_base64

test_list:
	$(CC) -g -I$(LIBR_INCLUDE) test_list.c $(LIBR_UTIL)/list.c -o test_list

test_base64:
	$(CC) -g -I$(LIBR_INCLUDE) test_base64.c $(LIBR_UTIL)/base64.c -o test_base64

clean:
	rm test_list test_base64

.PHONY: all test_list test_base64
