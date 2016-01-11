#include <r_list.h>
#include "minunit.h"

int tests_run = 0;
char* buf;

char* test_r_list_size(void) {
	// Test that r_list adding and deleting works correctly.
	int i;
	RList* list = r_list_new ();
	intptr_t test = 0x101010;
	// Add 100 items.
	for (i = 0; i < 100; ++i) {
		r_list_append (list, (void*)test);
		snprintf(buf, 1024, "error, append gave wrong length. actual %d, expected %d",
				r_list_length (list), i + 1);
		mu_assert(buf, i + 1 == r_list_length (list));
	}
	// Delete 50 of them.
	for (i = 0; i < 50; ++i) {
		intptr_t val = (intptr_t)r_list_pop (list);
		snprintf(buf, 1024, "error, pop gave wrong length. actual: %d, expected %d",
				r_list_length (list), 99 - i);
		mu_assert(buf, 99 - i == r_list_length (list));
	}
	// Purge the list.
	r_list_purge (list);
	mu_assert("error, purge didn't clear list", 0 == r_list_length (list));
	r_list_free (list);
	return NULL;
}

char* test_r_list_values(void) {
	RList* list = r_list_new ();
	intptr_t test1 = 0x12345;
	intptr_t test2 = 0x88888;
	r_list_append (list, (void*)test1);
	r_list_append (list, (void*)test2);
	mu_assert("error, first value not 0x88888",
			(intptr_t)0x88888 == (intptr_t)r_list_pop (list));
	mu_assert("error, first value not 0x12345",
			(intptr_t)0x12345 == (intptr_t)r_list_pop (list));
	r_list_free (list);
	return NULL;
}

char* test_r_list_join(void) {
	RList* list1 = r_list_new ();
	RList* list2 = r_list_new ();
	intptr_t test1 = 0x12345;
	intptr_t test2 = 0x88888;
	r_list_append (list1, (void*)test1);
	r_list_append (list2, (void*)test2);
	mu_assert("r_list_join returned non-success",
			r_list_join (list1, list2) == 1);
	mu_assert("r_list_join two single element lists result length is 1",
			r_list_length (list1) == 2);
	r_list_free (list1);
	r_list_free (list2);
	return NULL;
}


char* test_r_list_free(void) {
	RList* list = r_list_newf ((void*)0x9999);
	mu_assert("r_list_newf function gets set properly",
			list->free == (void*)0x9999);
	r_list_free (list);
	return NULL;
}

char* test_r_list_del_n(void) {
	RList* list = r_list_new ();
	intptr_t test1 = 0x12345;
	intptr_t test2 = 0x88888;
	r_list_append (list, (void*)test1);
	r_list_append (list, (void*)test2);
	snprintf (buf, 1024, "error, expected size 2, got %d\n", (int)r_list_length (list));
	mu_assert(buf, r_list_length (list) == 2);
	r_list_del_n (list, 0);
	mu_assert("error, first value not 0x88888",
			(intptr_t)0x88888 == (intptr_t)r_list_pop (list));
	r_list_free (list);
	return NULL;
}

char* test_r_list_sort(void) {
	int bad = 0;
	RList* list = r_list_new ();
	char* test1 = "AAAA";
	char* test2 = "BBBB";
	char* test3 = "CCCC";
	// Put in not sorted order.
	r_list_append (list, (void*)test1);
	r_list_append (list, (void*)test3);
	r_list_append (list, (void*)test2);
	// Sort.
	r_list_sort (list, (RListComparator)strcmp);
	// Check that the list is actually sorted.
	bad |= strcmp ("AAAA", list->head->data);
	bad |= strcmp ("BBBB", list->head->n->data);
	bad |= strcmp ("CCCC", list->head->n->n->data);
	mu_assert("error, list not sorted properly", bad == 0);
	r_list_free (list);
	return NULL;
}

char* all_tests() {
	mu_run_test(test_r_list_size);
	mu_run_test(test_r_list_values);
	mu_run_test(test_r_list_join);
	mu_run_test(test_r_list_free);
	mu_run_test(test_r_list_del_n);
	mu_run_test(test_r_list_sort);
	return NULL;
}

int main(int argc, char **argv) {
	buf = malloc (1024);
	char *result = all_tests();
	if (result != 0) {
		printf("%s\n", result);
	} else {
		printf("ALL TESTS PASSED\n");
	}
	printf("Tests run: %d\n", tests_run);
	free (buf);
	return result != 0;
}
