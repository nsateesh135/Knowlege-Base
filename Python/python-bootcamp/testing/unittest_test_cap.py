import unittest
import unitest_cap

class Testcap(unittest.TestCase):
    def test_one_word(self):
        text = "Python"
        result = unitest_cap.cap_text(text)
        self.assertEqual(result,'Python')
    def test_multiple_words(self):
        text = 'monty program'
        result = unitest_cap.cap_text(text)
        self.assertEqual(result,'Monty Program')

    def test_with_apostrophes(self):
        text = "monty python's car"
        result = unitest_cap.cap_text(text)
        self.assertEqual(result,"Monty Python's Car")
if __name__ == '__main__':
    unittest.main() 
