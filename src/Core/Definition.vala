public class Palaura.Core.Definition : Object {
    public string text;
    public string lexical_category;

    Sense[] senses = {};
    Pronunciation[] pronunciations = {};

    public static Core.Definition parse_json (Json.Object root) {

        Core.Definition obj = new Core.Definition ();

        if (root.has_member ("text"))
            obj.text = root.get_string_member ("text");

        if (root.has_member ("lexicalCategory")) {
            Json.Object category = root.get_object_member ("lexicalCategory");
            if (category.has_member ("text"))
                obj.lexical_category = category.get_string_member ("text");
        }

        if (root.has_member ("pronunciations")) {
            Json.Array pronunciations = root.get_array_member ("pronunciations");
            foreach (var pronunciation in pronunciations.get_elements())
                obj.pronunciations += Pronunciation.parse_json (pronunciation.get_object ());
        }

        if (root.has_member ("entries")) {
            Json.Array entries = root.get_array_member ("entries");
            var obj_entries = entries.get_object_element(0);
            Json.Array senses = obj_entries.get_array_member("senses");
            foreach (var sense in senses.get_elements())
                obj.senses += Sense.parse_json (sense.get_object ());
        }

        return obj;

    }

    public class Sense {
        string[] definitions = {};
        Example[] examples = {};
        Synonym[] synonyms = {};
        Antonym[] antonyms = {};

        public string[] get_definitions () {
            return definitions;
        }

        public Example[] get_examples () {
            return examples;
        }

        public Synonym[] get_synonyms () {
            return synonyms;
        }

        public Antonym[] get_antonyms () {
            return antonyms;
        }

        public class Example {
            public string text;

            public static Example parse_json (Json.Object root) {
                Example obj = new Example ();

                if (root.has_member ("text"))
                    obj.text = root.get_string_member ("text");

                return obj;
            }
        }

        public class Synonym {
            public string text;

            public static Synonym parse_json (Json.Object root) {
                Synonym obj = new Synonym ();

                if (root.has_member ("text"))
                    obj.text = root.get_string_member ("text");

                return obj;
            }
        }

        public class Antonym {
            public string text;

            public static Antonym parse_json (Json.Object root) {
                Antonym obj = new Antonym ();

                if (root.has_member ("text"))
                    obj.text = root.get_string_member ("text");

                return obj;
            }
        }

        public static Sense parse_json (Json.Object root) {
            Sense obj = new Sense();

            if (root.has_member ("definitions")) {
                Json.Array definitions = root.get_array_member ("definitions");
                foreach (var definition in definitions.get_elements ())
                    obj.definitions += definition.get_string ();
            }

            if (root.has_member ("examples")) {
                Json.Array examples = root.get_array_member ("examples");
                foreach (var example in examples.get_elements ())
                    obj.examples += Example.parse_json (example.get_object ());
            }

            if (root.has_member ("synonyms")) {
                Json.Array synonyms = root.get_array_member ("synonyms");
                foreach (var synonym in synonyms.get_elements ())
                    obj.synonyms += Synonym.parse_json (synonym.get_object ());
            }

            if (root.has_member ("antonyms")) {
                Json.Array antonyms = root.get_array_member ("antonyms");
                foreach (var antonym in antonyms.get_elements ())
                    obj.antonyms += Antonym.parse_json (antonym.get_object ());
            }

            return obj;
        }
    }

    public class Pronunciation {
        public string phonetic_spelling;

        public static Pronunciation parse_json(Json.Object root) {
            Pronunciation obj = new Pronunciation();

            if (root.has_member ("phoneticSpelling"))
                obj.phonetic_spelling = root.get_string_member("phoneticSpelling");

            return obj;
        }
    }

    public Pronunciation[] get_pronunciations () {
        return pronunciations;
    }

    public Sense[] get_senses () {
        return senses;
    }
}
