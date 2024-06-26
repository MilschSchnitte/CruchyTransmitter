package de.milschschnitte.crunchytransmitter.reciever;

import java.time.DayOfWeek;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public enum EnumWeekdays {
    MONDAY("Montag"),
    TUESDAY("Dienstag"),
    WEDNESDAY("Mittwoch"),
    THURSDAY("Donnerstag"),
    FRIDAY("Freitag"),
    SATURDAY("Samstag"),
    SUNDAY("Sonntag");

    private final String germanName;
    static Logger logger = LoggerFactory.getLogger(EnumWeekdays.class);

    EnumWeekdays(String germanName) {
        this.germanName = germanName;
    }

    public String getGermanName() {
        return germanName;
    }

    public static EnumWeekdays fromGermanName(String germanName) {
        if (germanName.startsWith("\"") && germanName.endsWith("\"")) {
            germanName = germanName.substring(1, germanName.length() - 1);
        }

        for (EnumWeekdays day : values()) {
            if (day.getGermanName().equalsIgnoreCase(germanName)) {
                return day;
            }
        }
        return null;
    }

    public static DayOfWeek getDayOfWeek(EnumWeekdays enumWeekday) {
        switch (enumWeekday) {
            case MONDAY:
                return DayOfWeek.MONDAY;
            case TUESDAY:
                return DayOfWeek.TUESDAY;
            case WEDNESDAY:
                return DayOfWeek.WEDNESDAY;
            case THURSDAY:
                return DayOfWeek.THURSDAY;
            case FRIDAY:
                return DayOfWeek.FRIDAY;
            case SATURDAY:
                return DayOfWeek.SATURDAY;
            case SUNDAY:
                return DayOfWeek.SUNDAY;
            default:
                logger.warn("Unknown weekday: " + enumWeekday);
                throw new RuntimeException();
        }
    }

    public static boolean isInCurrentWeek(Date date) {
        Calendar calendar = Calendar.getInstance(Locale.GERMANY);
        calendar.setFirstDayOfWeek(Calendar.MONDAY);
        calendar.setTime(date);
        int currentWeek = calendar.get(Calendar.WEEK_OF_YEAR);

        Calendar today = Calendar.getInstance(Locale.GERMANY);
        today.setFirstDayOfWeek(Calendar.MONDAY);
        int currentYear = today.get(Calendar.YEAR);
        int currentWeekOfYear = today.get(Calendar.WEEK_OF_YEAR);

        return calendar.get(Calendar.YEAR) == currentYear && currentWeek == currentWeekOfYear;
    }
}
