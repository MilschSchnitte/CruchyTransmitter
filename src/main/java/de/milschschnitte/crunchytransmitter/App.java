package de.milschschnitte.crunchytransmitter;

import javax.naming.ConfigurationException;

import de.milschschnitte.crunchytransmitter.database.DatabaseManager;
import de.milschschnitte.crunchytransmitter.reciever.JsonEpisodeFetcher;

/**
 * Hello world!
 *
 */
public class App 
{
    public static void main( String[] args ) throws ConfigurationException
    {
        ConfigLoader cl = new ConfigLoader();


        JsonEpisodeFetcher jep = new JsonEpisodeFetcher();
        jep.fetch();
    }
    //https://cr-news-api-service.prd.crunchyrollsvc.com/v1/de-DE/stories?slug=seasonal-lineup%2F2024%2F4%2F1%2Fcrunchyroll-wochenprogramm-fruehling-2024

    //Das %2F ist ein / die Website ist einfac hdie hauptseite in umgeformt
}
